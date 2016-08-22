require './math_utils.rb'

class LogfileParser
    URLREGEX = Regexp.union([
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
        @final_hash['count_pending']['dyno'] = Array.new
        @final_hash['count_pending']['response_time'] = Array.new

        @final_hash['get_messages'] = Hash.new
        @final_hash['get_messages']['dyno'] = Array.new
        @final_hash['get_messages']['response_time'] = Array.new

        @final_hash['friends_progress'] = Hash.new
        @final_hash['friends_progress']['dyno'] = Array.new
        @final_hash['friends_progress']['response_time'] = Array.new

        @final_hash['friends_score'] = Hash.new
        @final_hash['friends_score']['dyno'] = Array.new
        @final_hash['friends_score']['response_time'] = Array.new

        @final_hash['post_users'] = Hash.new
        @final_hash['post_users']['dyno'] = Array.new
        @final_hash['post_users']['response_time'] = Array.new

        @final_hash['get_users'] = Hash.new
        @final_hash['get_users']['dyno'] = Array.new
        @final_hash['get_users']['response_time'] = Array.new
    end

    attr_reader :final_hash

    def get_matched_lines &block
	    # line_num = 0
        @log.each_line do |line|
            if line =~ URLREGEX
                # print "#{line_num += 1} #{line}"
                yield line
            end
        end
    end

    def prepare_hash
       self.get_matched_lines {
           |l|
           dyno = c_time = s_time = ''

           dyno = l.match(/dyno=(.*) connect=(.*)ms service=(.*)ms/)[1]
           c_time = l.match(/dyno=(.*) connect=(.*)ms service=(.*)ms/)[2]
           s_time = l.match(/dyno=(.*) connect=(.*)ms service=(.*)ms/)[3]

           if l =~ /path=\/api\/users\/.*\/count_pending_messages (.*)/

               if @final_hash['count_pending']
                   if @final_hash['count_pending']['dyno']
                       @final_hash['count_pending']['dyno'].push(dyno.to_s)
                       @final_hash['count_pending']['response_time'].push(c_time.to_f + s_time.to_f)
                   end
               end
           end

           if l =~ /path=\/api\/users\/.*\/get_messages (.*)/

               if @final_hash['get_messages']
                   if @final_hash['get_messages']['dyno']
                       @final_hash['get_messages']['dyno'].push(dyno)
                       @final_hash['get_messages']['response_time'].push(c_time.to_f + s_time.to_f)
                   end
               end
           end

           if l =~ /path=\/api\/users\/.*\/get_friends_progress (.*)/

               if @final_hash['friends_progress']
                   if @final_hash['friends_progress']['dyno']
                       @final_hash['friends_progress']['dyno'].push(dyno)
                       @final_hash['friends_progress']['response_time'].push(c_time.to_f + s_time.to_f)
                   end
               end
           end

           if l =~ /path=\/api\/users\/.*\/get_friends_score (.*)/

               if @final_hash['friends_score']
                   if @final_hash['friends_score']['dyno']
                       @final_hash['friends_score']['dyno'].push(dyno)
                       @final_hash['friends_score']['response_time'].push(c_time.to_f + s_time.to_f)
                   end
               end
           end

           if l =~ /method=POST path=\/api\/users\/\d+ (.*)/

               if @final_hash['post_users']
                   if @final_hash['post_users']['dyno']
                       @final_hash['post_users']['dyno'].push(dyno)
                       @final_hash['post_users']['response_time'].push(c_time.to_f + s_time.to_f)
                   end
               end
           end

           if l =~ /method=GET path=\/api\/users\/\d+ (.*)/

               if @final_hash['get_users']
                   if @final_hash['get_users']['dyno']
                       @final_hash['get_users']['dyno'].push(dyno)
                       @final_hash['get_users']['response_time'].push(c_time.to_f + s_time.to_f)
                   end
               end
           end
       }
       
    end

    def get_results
        self.prepare_hash
        @final_hash.each do |key, value|

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
                puts "'#{key}' url called #{total_hit} times, mean=#{url_mean}, median=#{url_median} and mode(s)=#{url_mode}. Most frequent dyno(s)='#{url_dyno}'"
            else
                puts "#{key}' did not call by users"
            end

        end
    end

    def file_exists?
        File.exist?('./sample.log')
    end
end

parser = LogfileParser.new

# parser.get_matched_lines {|l| puts l}
parser.get_results


# m_str = ''
# mode([1,2,3,4,2,4]).each do |k,v| m_str << "#{k}," end
# puts m_str.chomp(',')
