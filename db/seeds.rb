ActiveRecord::Base.establish_connection(:development)
ActiveRecord::Base.connection.tables.each do |table|
  next if table == 'schema_migrations'
  ActiveRecord::Base.connection.execute('TRUNCATE %s CASCADE' % table)
end

login_counter = 1
ip_counter = 1

200_000.times do |n|
  params = 'login=login%s&title=title%s&content=content%s&author_ip=%s.%s.%s.%s' %[
    login_counter, n + 1, n + 1, ip_counter, ip_counter, ip_counter, ip_counter
  ]
  response = `curl -d "#{params}" "http://localhost:9393/create_post"`
  post_id = JSON.parse(response)['post']['id']
  if post_id % 10 == 0
    3.times do
      params = 'post_id=%s&value=%s' %[post_id, rand(1..5)]
      `curl -d "#{params}" "http://localhost:9393/rate_post"`
    end
  end
  login_counter = login_counter < 100 ? login_counter + 1 : 1
  ip_counter = ip_counter < 50 ? ip_counter + 1 : 1
end
