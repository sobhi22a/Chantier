using System.Collections.Concurrent;
using Microsoft.Extensions.Logging;

namespace Chantier.IntegrationTests.Support;

/// <summary>Capture tous les journaux du serveur (message, valeurs structurees et exception) pour y chercher des donnees personnelles.</summary>
public sealed class CapturingLoggerProvider : ILoggerProvider
{
    private readonly ConcurrentQueue<string> _entries = new();

    public IReadOnlyList<string> Entries => _entries.ToArray();

    public string AllText => string.Join(Environment.NewLine, _entries);

    public ILogger CreateLogger(string categoryName) => new CapturingLogger(categoryName, _entries);

    public void Dispose()
    {
    }

    private sealed class CapturingLogger(string category, ConcurrentQueue<string> entries) : ILogger
    {
        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;

        public bool IsEnabled(LogLevel logLevel) => true;

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception? exception, Func<TState, Exception?, string> formatter)
        {
            var structured = state is IEnumerable<KeyValuePair<string, object?>> pairs
                ? string.Join(' ', pairs.Select(pair => $"{pair.Key}={pair.Value}"))
                : string.Empty;

            entries.Enqueue($"[{logLevel}] {category}: {formatter(state, exception)} {structured} {exception}");
        }
    }
}
