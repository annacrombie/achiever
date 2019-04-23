Achiever.config do |c|
end

Achiever.visibilities.register(:custom) do |achievement|
  achievement.subject.age > 25
end
