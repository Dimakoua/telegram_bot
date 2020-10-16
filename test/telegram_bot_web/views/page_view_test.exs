defmodule TelegramBotWeb.PageViewTest do
  use TelegramBotWeb.ConnCase, async: true
  use Hound.Helpers

  hound_session()

  test "user can sign in with valid credentials" do
    navigate_to("/")
    elements = find_element(:css, "h1")
    text = visible_text(elements)
    assert text == "Welcome to Phoenix!"
  end

  test "link get started" do
    navigate_to("/")
    find_element(:css, "body > header > section > nav > ul > li > a") |> click()
    assert current_url() == "https://hexdocs.pm/phoenix/overview.html"
  end

  test "has input" do
    navigate_to("/setwebhook")
    element = find_element(:css, "body > main > form > input[type=text]:nth-child(1)")
    assert element_displayed?(element)
  end
end
