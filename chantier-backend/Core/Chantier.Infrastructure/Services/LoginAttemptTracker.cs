using System.Collections.Concurrent;
using Chantier.Core.Identity;
using Microsoft.Extensions.Options;

namespace Chantier.Infrastructure.Services;

/// <summary>
/// Echecs de connexion par identifiant normalise, <b>existant ou non</b> : un identifiant inconnu est bloque comme un autre,
/// donc le blocage ne revele jamais l'existence d'un compte (ADR 0005, CA-001.3/001.4). En memoire, instance unique.
/// </summary>
public sealed class LoginAttemptTracker(IOptions<AuthSettings> options, TimeProvider time) : ILoginAttemptTracker
{
    private const int CleanupThreshold = 5000;

    private readonly ConcurrentDictionary<string, Queue<DateTimeOffset>> _failures = new(StringComparer.Ordinal);

    private TimeSpan Window => TimeSpan.FromMinutes(Math.Max(1, options.Value.LockoutMinutes));

    private int Max => Math.Max(1, options.Value.MaxFailedAttempts);

    public TimeSpan? GetRetryAfter(string identifier)
    {
        if (!_failures.TryGetValue(identifier, out var queue))
        {
            return null;
        }

        var now = time.GetUtcNow();
        lock (queue)
        {
            Prune(queue, now);
            return queue.Count >= Max ? queue.Peek() + Window - now : null;
        }
    }

    public void RegisterFailure(string identifier)
    {
        var now = time.GetUtcNow();
        var queue = _failures.GetOrAdd(identifier, _ => new Queue<DateTimeOffset>());
        lock (queue)
        {
            Prune(queue, now);
            queue.Enqueue(now);
        }

        if (_failures.Count > CleanupThreshold)
        {
            Cleanup(now);
        }
    }

    public void Reset(string identifier) => _failures.TryRemove(identifier, out _);

    private void Prune(Queue<DateTimeOffset> queue, DateTimeOffset now)
    {
        while (queue.Count > 0 && queue.Peek() + Window <= now)
        {
            queue.Dequeue();
        }
    }

    private void Cleanup(DateTimeOffset now)
    {
        foreach (var (key, queue) in _failures)
        {
            lock (queue)
            {
                Prune(queue, now);
                if (queue.Count == 0)
                {
                    _failures.TryRemove(key, out _);
                }
            }
        }
    }
}
