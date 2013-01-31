#!/usr/bin/ruby

require 'pg'

host = 'localhost'
port = 5432
db = 'structure'
table = 'entries'

command = ARGV[0]
activity = ARGV[1]
description = ARGV[2]

conn = PG::Connection.new(:dbname => db, :host => host, :port => port)
time = Time.now.to_s

if command == 'start' 
	result = conn.exec("INSERT INTO #{table} (start_at, activity, description)
											VALUES ($1, $2, $3)",
						[time, activity, description])
elsif command == 'end'
	last = conn.exec("SELECT * FROM #{table} ORDER BY id DESC LIMIT 1")[0]
	activity ||= last['activity']
	description ||= last['description']
	result = conn.exec("UPDATE #{table} SET end_at = $2,
											activity = $3,
											description = $4
										WHERE id = $1",
						[last['id'], time, activity, description])
end
conn.finish