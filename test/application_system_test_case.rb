require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  DRIVER = :headless_chrome
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def start(page_class, params = {})
    @page = page_class.new(self, params)
    @page.visit
  end

  def transition(page_class, params = {})
    @page = page_class.new(self, params)
    assert_transition
  end

  def wait_until(time: Capybara.default_max_wait_time)
    Timeout.timeout(time) do
      sleep 0.2
      until (value = yield)
        sleep(0.1)
      end
      value
    end
  end

  private

  def assert_transition
    wait_until(time: 3) do
      @page.page_path == current_path
    end
    assert_equal @page.page_path, current_path
  rescue Timeout::Error
    assert_equal @page.page_path, current_path
  end
end

Capybara.save_path = Rails.root.join("tmp/capybara")