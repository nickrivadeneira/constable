defmodule Constable.Api.AnnouncementControllerTest do
  use Constable.ConnCase

  alias Constable.Announcement
  @view Constable.Api.AnnouncementView

  setup do
    {:ok, authenticate}
  end

  test "#index lists all announcements", %{conn: conn, user: user} do
    announcements = create_pair(:announcement, user: user)

    conn = get conn, announcement_path(conn, :index)

    assert json_response(conn, 200) == render_json("index.json", announcements: announcements)
  end

  test "#show renders single announcement", %{conn: conn, user: user} do
    announcement = create(:announcement, user: user)

    conn = get conn, announcement_path(conn, :show, announcement.id)

    assert json_response(conn, 200) == render_json("show.json", announcement: announcement)
  end

  test "#create with valid attributes saves an announcement", %{conn: conn} do
    announcement_params = build(:announcement_params)

    conn = post conn, announcement_path(conn, :create), %{
      announcement: announcement_params,
      interest_names: ["foo"]
    }

    announcement = Repo.one(Announcement) |> Repo.preload(:interests)
    interest_names = Enum.map(announcement.interests, fn(interest) ->
      interest.name
    end)

    assert json_response(conn, 201)
    assert announcement.title == announcement_params.title
    assert announcement.body == announcement_params.body
    assert interest_names == ["foo"]
  end

  test "#create with invalid attributes renders errors", %{conn: conn} do
    conn = post conn, announcement_path(conn, :create), announcement: %{}, interest_names: %{}

     assert %{"errors" => _} = json_response(conn, 422)
  end

  test "#update with valid attributes updates announcement", %{conn: conn, user: user} do
    announcement = create(:announcement, user: user, title: "Foo")

    put conn, announcement_path(conn, :update, announcement), announcement: %{
      title: "Foobar"
    }

    announcement = Repo.one(Announcement)
    assert announcement.title == "Foobar"
  end

  test "#update with invalid attributes renders errors", %{conn: conn, user: user} do
    announcement = create(:announcement, user: user)

    conn = put conn, announcement_path(conn, :update, announcement), announcement: %{
      title: nil,
      body: nil
    }

    assert %{"errors" => _} = json_response(conn, 422)
  end

  test "#update only creator can update attributes", %{conn: conn} do
    other_user = create(:user)
    announcement = create(:announcement, user: other_user)

    conn = put conn, announcement_path(conn, :update, announcement), announcement: %{}

    assert response(conn, 401)
  end

  test "#delete deletes announcement", %{conn: conn, user: user} do
    announcement = create(:announcement, user: user)

    conn = delete conn, announcement_path(conn, :delete, announcement)

    assert Repo.count(Announcement) == 0
    assert response(conn, 204)
  end

  test "#delete only owner can delete announcement", %{conn: conn} do
    other_user = create(:user)
    announcement = create(:announcement, user: other_user)

    conn = delete conn, announcement_path(conn, :delete, announcement)

    assert response(conn, 401)
  end
end