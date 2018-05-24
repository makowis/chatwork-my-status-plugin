#! /bin/sh
exec ruby -S -x "$0" "$@"
#! ruby
require 'net/http'
require 'json'
require 'uri'

if ENV['MACKEREL_AGENT_PLUGIN_META'] == '1'
  require 'json'
  
  meta = {
    graphs: {
      'chatowrk.my.status' => {
        label: 'ChatWork My Status',
        unit: 'integer',
        metrics: [
          {
            name: 'unread_room_num',
            label: '未読ルーム数'
          }, {
            name: 'mention_room_num',
            label: '未読Toルーム数'
          }, {
            name: 'mytask_room_num',
            label: 'タスク有ルーム数'
          }, {
            name: 'unread_num',
            label: '未読数'
          }, {
            name: 'mention_num',
            label: '未読To数'
          }, {
            name: 'mytask_num',
            label: '未完了タスク数'
          }
        ]
      }
    }
  }

  puts '# mackerel-agent-plugin'
  puts meta.to_json
  exit 0
end

url = URI.parse('https://api.chatwork.com/v2/my/status')
req = Net::HTTP::Get.new(url.request_uri)
req['X-ChatWorkToken'] = ENV['CHATWORK_API_TOKEN']

res = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
  http.request(req)
end

json = res.body
result = JSON.parse(json)

now = Time.now.to_i
result.each do |key, value|
  puts [ "chatowrk.my.status.#{key}",  value,  now].join("\t")    
end
