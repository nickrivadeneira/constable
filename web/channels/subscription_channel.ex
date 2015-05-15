defmodule Constable.SubscriptionChannel do
  use Constable.AuthorizedChannel
  alias Constable.Repo
  alias Constable.Subscription
  alias Constable.Serializers
  alias Constable.Queries

  def handle_in("subscriptions:index", _params, socket) do
    user_id = current_user_id(socket)
    subscriptions =
      Repo.all(Queries.Subscription.for_user(user_id))
      |> Enum.map(&preload_associations/1)
      |> Serializers.ids_as_keys

      {:reply, %{subscriptions: subscriptions}, socket}
  end

  def handle_in("create", %{"subscription" =>  subscription}, socket) do
    user_id = current_user_id(socket)
    subscription = Subscription.changeset(%{
      user_id: user_id,
      announcement_id: Map.get(subscription, "announcement_id")
    }) |> Repo.insert

    {:reply, {:ok, %{subscription: subscription}}, socket}
  end

  def handle_in("delete", %{"id" => id}, socket) do
    Repo.get(Subscription, id) |> Repo.delete

    {:reply, :ok, socket}
  end

  defp preload_associations(subscription) do
    Repo.preload(subscription, [:announcement, :user])
  end
end