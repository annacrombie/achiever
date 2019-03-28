# frozen_string_literal: true

namespace :achiever do
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
