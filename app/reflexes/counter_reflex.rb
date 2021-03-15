class CounterReflex < ApplicationReflex
  def initialize()
    @count = 0
  end

  def increment
    @count = @count + 1
  end
end