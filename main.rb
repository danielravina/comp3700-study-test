require "json"
require "nokogiri"
require "colorize"

def display
  count = @current_question_index.to_s << "/" << @questions.length.to_s << " "
  puts count.yellow  <<  display_question.yellow
  puts "(1) ".light_red << @options[0].light_blue
  puts "(2) ".light_red << @options[1].light_blue
  puts "(3) ".light_red << @options[2].light_blue
  puts "(4) ".light_red << @options[3].light_blue
end

def init
  puts "=======================================".light_blue
  puts "COMP 3700 prep. Press q + enter to exit".light_blue
  puts "=======================================".light_blue
  puts
  parse_json
  set_all_answers
  @current_question_index = 0
  @score = {right: 0, wrong: 0}
end

def start
  ask
  set_options
  display
  answer
end

def set_options
  @options = [
    @current_answer[:text].to_s,
    random_answer,
    random_answer,
    random_answer
  ]

  @options.shuffle!

  @options_map = {
    "1" => @options[0],
    "2" => @options[1],
    "3" => @options[2],
    "4" => @options[3]
  }

end

def parse_json
  f = File.read "data.json"
  @questions = JSON.parse(f)
  @questions.shuffle!
  # @questions.reverse!
end

def ask
  if @current_question_index < @questions.length
    @current_question = @questions[@current_question_index]
    @current_answer   = parse_answer @current_question
    @current_question_index +=1
  else
    display_score
    exit
  end
end

def answer
  print "A:  "
  user_answer = gets
  user_answer = user_answer.downcase.strip.to_s
  if user_answer == "q"
    display_score
    exit
  else
    if is_correct_option? user_answer
    # if is_correct_answer? user_answer
      puts "=+=+=+=+=+=+".green
      puts "  CORRECT!".green
      puts "=+=+=+=+=+=+".green
      @score[:right] += 1
    else
      puts "=+=+=+=+=+=+=+=+=+=+".red
      puts "  WRONG!".red
      puts "  Answer is:" << " #{@current_answer[:text].downcase}".green
      puts "=+=+=+=+=+=+=+=+=+=+".red
      @score[:wrong] += 1
    end
    start # Next question...
  end
end

def is_correct_answer? answer_text
  answer_text == @current_answer[:text].downcase
end

def is_correct_option? answer_index
  if ["1", "2", "3", "4"].include? answer_index
    answer_text = @options_map[answer_index].downcase
    answer_text == @current_answer[:text].downcase
  else
    display
    answer
  end
end

def set_all_answers
  @answers = @questions.map do |q|
    parse_answer q
  end
  @answers.shuffle!
end

def random_answer
  @answers[rand(0..@answers.length-1)][:text].to_s
end

def parse_answer q
  q = Nokogiri.HTML q["back"]["text"]
  {id: q["id"], text:  q.inner_text}
end

def display_question
  Nokogiri.HTML(@current_question["front"]["text"]).inner_text
end

def display_score
  percent = ((@score[:right].to_f/@current_question_index.to_f)*100).round.to_s rescue "0"
  puts "Your score is: #{percent}%"
  puts "======================="
  puts "Questions: " << @current_question_index.to_s
  puts "Right: "     << @score[:right].to_s
  puts "Wrong: "     << @score[:wrong].to_s
end

init
start