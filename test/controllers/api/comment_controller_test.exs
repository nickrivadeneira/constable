defmodule Constable.Api.CommentControllerTest do
  import Ecto.Query
  use Constable.ConnCase

  alias Constable.Comment

  setup do
    {:ok, authenticate}
  end

  test "#create creates a comment for user and announcement", %{conn: conn, user: user} do
    announcement = create(:announcement)

    conn = post conn, comment_path(conn, :create), comment: %{
      body: "Foo",
      announcement_id: announcement.id
    }

    assert json_response(conn, 201)
    comment = Repo.one(Comment)
    assert comment.body == "Foo"
    assert comment.user_id == user.id
    assert comment.announcement_id == announcement.id
  end
end