# frozen_string_literal: true

namespace :achiever do
  desc 'test'
  task benchmark: :environment do
    require 'benchmark/ips'
    Benchmark.ips do |b|
      b.report("normal") {  Achiever::Achievement.new(name: 'logins', subject_id: 123) }
      b.report("abnorm") {  Achiever::ScheduledAchievement.new(achievement_id: 1) }
      b.compare!
    end
  end

  desc 'remove achievements with invalid names'
  task cleanup: :environment do
    rel = Achiever::Achievement.where.not(name: Achiever.achievements.keys)
    print("Really delete #{rel.count} achievements? [Y/n] ")
    case $stdin.gets.chomp
    when 'Y', 'y'
      puts('deleting...')
      rel.delete_all
    else
      puts('exiting...')
    end
  end
end
