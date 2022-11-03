#!/usr/bin/env ruby

# E.g. bundle exec ./end_of_dst.rb Europe/London America/New_York

require "tzinfo"
require "terminal-table"

zonename1 = ARGV[0]
zonename2 = ARGV[1]

tz1 = TZInfo::Timezone.get(zonename1)
tz2 = TZInfo::Timezone.get(zonename2)

dst_entrances1 = tz1.transitions_up_to(Time.now).select { |transition|
  transition.offset.std_offset == 3600 &&
    transition.previous_offset.std_offset == 0
}
dst_entrance_days1 = dst_entrances1.map { |transition| transition.local_end_at.to_time }

dst_entrances2 = tz2.transitions_up_to(Time.now).select { |transition|
  transition.offset.std_offset == 3600 &&
    transition.previous_offset.std_offset == 0
}
dst_entrance_days2 = dst_entrances2.map { |transition| transition.local_end_at.to_time }

dst_exits1 = tz1.transitions_up_to(Time.now).select { |transition|
  transition.offset.std_offset == 0 &&
    transition.previous_offset.std_offset == 3600
}
dst_exit_days1 = dst_exits1.map { |transition| transition.local_end_at.to_time }

dst_exits2 = tz2.transitions_up_to(Time.now).select { |transition|
  transition.offset.std_offset == 0 &&
    transition.previous_offset.std_offset == 3600
}
dst_exit_days2 = dst_exits2.map { |transition| transition.local_end_at.to_time }

earliest_year1 = dst_exit_days1.map { |time| time.year }.sort.first
earliest_year2 = dst_exit_days2.map { |time| time.year }.sort.first
earliest_year = [earliest_year1, earliest_year2].min
# earliest_year = [earliest_year, 1980].max

latest_year1 = dst_exit_days1.map { |time| time.year }.sort.last
latest_year2 = dst_exit_days2.map { |time| time.year }.sort.last
latest_year = [latest_year1, latest_year2].max

output = []
output.push ["year", "#{zonename1} start", "#{zonename2} start", "difference in days", "#{zonename1} start", "#{zonename2} start", "difference in days"]

earliest_year.upto(latest_year) do |year|
  entrance1 = dst_entrance_days1.select{ |time| time.year == year}[0]
  entrance2 = dst_entrance_days2.select{ |time| time.year == year}[0]
  
  exit1 = dst_exit_days1.select{ |time| time.year == year}[0]
  exit2 = dst_exit_days2.select{ |time| time.year == year}[0]
  next unless entrance1 && entrance2 && exit1 && exit2
  
  output.push [
    year,
    entrance1.strftime("%d %B"), entrance2.strftime("%d %B"), ((entrance2 - entrance1)/(24*60*60)).to_i,
    exit1.strftime("%d %B"), exit2.strftime("%d %B"), ((exit2 - exit1)/(24*60*60)).to_i
  ]
end

puts Terminal::Table.new rows: output