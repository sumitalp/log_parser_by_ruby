# require "benchmark"
require './math_utils'

class LogfileParser
    URL_REGEX = Regexp.union([
                              /path=\/api\/users\/.*\/count_pending_messages (.*)/,
                              /path=\/api\/users\/.*\/get_messages (.*)/,
                              /path=\/api\/users\/.*\/get_friends_progress (.*)/,
                              /path=\/api\/users\/.*\/get_friends_score (.*)/,
                              /method=POST path=\/api\/users\/\d+ (.*)/,
                              /method=GET path=\/api\/users\/\d+ (.*)/
                             ])
    def initialize
        @log = File.open('./sample.log')
        @final_hash = Hash.new(0)

        @final_hash['count_pending'] = Hash.new
        @final_hash['count_pending']['path'] = '/api/users/{user_id}/count_pending_messages'
        @final_hash['count_pending']['dyno'] = Array.new
        @final_hash['count_pending']['response_time'] = Array.new

        @final_hash['get_messages'] = Hash.new
        @final_hash['get_messages']['path'] = '/api/users/{user_id}/get_messages'
        @final_hash['get_messages']['dyno'] = Array.new
        @final_hash['get_messages']['response_time'] = Array.new

        @final_hash['friends_progress'] = Hash.new
        @final_hash['friends_progress']['path'] = '/api/users/{user_id}/get_friends_progress'
        @final_hash['friends_progress']['dyno'] = Array.new
        @final_hash['friends_progress']['response_time'] = Array.new

        @final_hash['friends_score'] = Hash.new
        @final_hash['friends_score']['path'] = '/api/users/{user_id}/get_friends_score'
        @final_hash['friends_score']['dyno'] = Array.new
        @final_hash['friends_score']['response_time'] = Array.new

        @final_hash['post_users'] = Hash.new
        @final_hash['post_users']['path'] = 'POST /api/users/{user_id}'
        @final_hash['post_users']['dyno'] = Array.new
        @final_hash['post_users']['response_time'] = Array.new

        @final_hash['get_users'] = Hash.new
        @final_hash['get_users']['path'] = 'GET /api/users/{user_id}'
        @final_hash['get_users']['dyno'] = Array.new
        @final_hash['get_users']['response_time'] = Array.new
    end

    attr_reader :final_hash

    def get_matched_lines
        @log.each_line do |line|
            if line =~ URL_REGEX
                yield line
            end
        end
        @log.close
    end

    def prepare_hash
       '''
       Method to prepare our final hash
       '''
       self.get_matched_lines { |l|

           matches = l.match(/dyno=(.*) connect=(.*)ms service=(.*)ms/)
           dyno = matches[1]
           c_time = matches[2]
           s_time = matches[3]

           if l =~ /path=\/api\/users\/.*\/count_pending_messages (.*)/

               self.build_hash('count_pending', dyno, (c_time.to_f+s_time.to_f))
           end

           if l =~ /path=\/api\/users\/.*\/get_messages (.*)/

               self.build_hash('get_messages', dyno, (c_time.to_f+s_time.to_f))
           end

           if l =~ /path=\/api\/users\/.*\/get_friends_progress (.*)/

               self.build_hash('friends_progress', dyno, (c_time.to_f+s_time.to_f))
           end

           if l =~ /path=\/api\/users\/.*\/get_friends_score (.*)/

               self.build_hash('friends_score', dyno, (c_time.to_f+s_time.to_f))
           end

           if l =~ /method=POST path=\/api\/users\/\d+ (.*)/

               self.build_hash('post_users', dyno, (c_time.to_f+s_time.to_f))
           end

           if l =~ /method=GET path=\/api\/users\/\d+ (.*)/

               self.build_hash('get_users', dyno, (c_time.to_f+s_time.to_f))
           end
       }
       
    end

    def build_hash(root_hash, dyno, response_time)
        '''
        Push data into parent hash
        '''
        @final_hash[root_hash]['dyno'].push(dyno)
        @final_hash[root_hash]['response_time'].push(response_time)
    end

    def get_results
        '''
        This method is responsible to print output at console
        '''
        self.prepare_hash

        line_num = 0
        puts '********** Start Output **********'
        @final_hash.each do |key, value|
            path = value['path']
            total_hit = value['dyno'].length
            url_dyno = ''
            most_common_value(value['dyno']).each do |ke,va| url_dyno << "#{ke}," end
            url_dyno = url_dyno.chomp(',')

            url_mean = mean(value['response_time'])
            url_median = median(value['response_time'])
            url_mode = ''
            mode(value['response_time']).each do |ke,va| url_mode << "#{ke}," end
            url_mode = url_mode.chomp(',')

            if total_hit > 0
                puts "#{line_num +=1}. '#{path}' url called #{total_hit} times, mean=#{url_mean}, median=#{url_median} and mode(s)=#{url_mode}. Most frequent dyno(s)='#{url_dyno}'"
            else
                puts "#{line_num +=1}. '#{path}' did not call by users"
            end

        end
        puts '********** End Output **********'
    end

    def file_exists?
        File.exist?('./sample.log')
    end
end

# Benchmark.bm(7) do |x|
#   x.report(){
#       parser = LogfileParser.new
#
#       parser.get_results
#   }
#
# end

parser = LogfileParser.new

parser.get_results
