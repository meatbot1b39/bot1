require 'wit'
require 'securerandom'

access_token = ENV["ACCESS_TOKEN"]

def first_entity_value(entities, entity)
  return nil unless entities.has_key? entity
  val = entities[entity][0]['value']
  return nil if val.nil?
  return val.is_a?(Hash) ? val['value'] : val
end

actions = {
  :say => -> (session_id, context, msg) {
    p msg
  },
  :merge => -> (session_id, context, entities, msg) {
    p "entities: #{entities}"
    p "context: #{context}"
    movie = first_entity_value(entities, 'movie')
    p "movie: #{movie}"
    p "movie class: #{movie.class.name}"
    context['movie'] = movie unless movie.nil?

    requested_time = first_entity_value(entities, 'datetime')
    context['requestedTime'] = requested_time unless requested_time.nil?

    p "requested_time: #{requested_time}"
    p "requested_time class: #{requested_time.class.name}"
    return context
  },
  :error => -> (session_id, context, error) {
    p error.message
  },
  :findTheater => -> (session_id, context) {
    context['showTime'] = 'midnight'
    context['theater'] = 'The Egyptian'
    return context
  }
}

def gen_session_id()
  "session-#{SecureRandom.uuid}"
end

def prompt_user()
  print '>'
  gets.chomp
end

client = Wit.new(access_token, actions)
session_id = gen_session_id

context = {}
while true
  msg = prompt_user()
  puts "DEBUG: [#{msg}]"
  context = client.run_actions(session_id, msg, context)
end
