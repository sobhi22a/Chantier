using Chantier.Core.Identity;
using Chantier.Infrastructure.Services;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Time.Testing;

namespace Chantier.UnitTests.Identity;

[TestFixture]
public class LoginAttemptTrackerTests
{
    private FakeTimeProvider _time = null!;
    private LoginAttemptTracker _tracker = null!;

    [SetUp]
    public void SetUp()
    {
        _time = new FakeTimeProvider(new DateTimeOffset(2026, 11, 24, 8, 0, 0, TimeSpan.Zero));
        _tracker = new LoginAttemptTracker(Options.Create(new AuthSettings()), _time);
    }

    [Test]
    public void Four_failures_do_not_block()
    {
        for (var i = 0; i < 4; i++)
        {
            _tracker.RegisterFailure("CHEF.DEV");
        }

        Assert.That(_tracker.GetRetryAfter("CHEF.DEV"), Is.Null);
    }

    [Test]
    public void Five_failures_block_for_fifteen_minutes_from_the_first_one()
    {
        for (var i = 0; i < 5; i++)
        {
            _tracker.RegisterFailure("CHEF.DEV");
            _time.Advance(TimeSpan.FromMinutes(1));
        }

        var wait = _tracker.GetRetryAfter("CHEF.DEV");

        Assert.That(wait, Is.EqualTo(TimeSpan.FromMinutes(10)), "Le premier échec date de 5 minutes : il reste 10 minutes.");
    }

    [Test]
    public void The_block_ends_when_the_oldest_failure_leaves_the_window()
    {
        for (var i = 0; i < 5; i++)
        {
            _tracker.RegisterFailure("CHEF.DEV");
        }

        _time.Advance(TimeSpan.FromMinutes(15));

        Assert.That(_tracker.GetRetryAfter("CHEF.DEV"), Is.Null);
    }

    [Test]
    public void Identifiers_are_independent()
    {
        for (var i = 0; i < 5; i++)
        {
            _tracker.RegisterFailure("A");
        }

        Assert.Multiple(() =>
        {
            Assert.That(_tracker.GetRetryAfter("A"), Is.Not.Null);
            Assert.That(_tracker.GetRetryAfter("B"), Is.Null);
        });
    }

    [Test]
    public void Reset_clears_the_counter()
    {
        for (var i = 0; i < 5; i++)
        {
            _tracker.RegisterFailure("A");
        }

        _tracker.Reset("A");

        Assert.That(_tracker.GetRetryAfter("A"), Is.Null);
    }

    [Test]
    public void Thresholds_are_configurable()
    {
        var tracker = new LoginAttemptTracker(Options.Create(new AuthSettings { MaxFailedAttempts = 2, LockoutMinutes = 1 }), _time);
        tracker.RegisterFailure("A");
        tracker.RegisterFailure("A");

        Assert.That(tracker.GetRetryAfter("A"), Is.EqualTo(TimeSpan.FromMinutes(1)));
    }

    [Test]
    public void Concurrent_failures_are_all_counted()
    {
        Parallel.For(0, 200, _ => _tracker.RegisterFailure("A"));

        Assert.That(_tracker.GetRetryAfter("A"), Is.Not.Null);
    }

    [Test]
    public void Permission_version_is_stable_and_order_independent()
    {
        var first = PermissionVersion.Compute(["Zones.View", "Sites.View"]);
        var second = PermissionVersion.Compute(["Sites.View", "Zones.View"]);
        var different = PermissionVersion.Compute(["Sites.View"]);

        Assert.Multiple(() =>
        {
            Assert.That(first, Is.EqualTo(second));
            Assert.That(first, Has.Length.EqualTo(8));
            Assert.That(first, Is.Not.EqualTo(different));
        });
    }
}
