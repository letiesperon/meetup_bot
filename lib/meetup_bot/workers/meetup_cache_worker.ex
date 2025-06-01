defmodule MeetupBot.MeetupCacheWorker do
  use Oban.Worker

  require OpenTelemetry.Tracer

  alias MeetupBot.MeetupCache
  alias MeetupBot.Meetup
  alias MeetupBot.Event
  alias OpenTelemetry.Tracer

  @impl true
  def perform(%Oban.Job{}) do
    Tracer.with_span "oban.perform" do
      Tracer.set_attributes([{:worker, "MeetupCacheWorker"}])

      events = Meetup.fetch_upcoming_meetups()
      MeetupCache.update_or_create(events)
      MeetupCache.delete_events_not_present_in_source(Event.meetup_source(), events)

      :ok
    end
  end
end
