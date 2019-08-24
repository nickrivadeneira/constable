defmodule ConstableWeb.ControllerHelper do
  def unauthorized(conn) do
    Plug.Conn.send_resp(conn, 401, "")
  end

  def current_user(_conn) do
    # TODO: revert, testing
    Constable.Repo.get!(Constable.User, 1)
    # conn.assigns[:current_user]
  end

  def page_title(conn, title) do
    Plug.Conn.assign(conn, :page_title, title)
  end
end
