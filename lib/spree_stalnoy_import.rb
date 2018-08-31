require 'spree_core'
require 'spree_stalnoy_import/engine'
require 'spree_stalnoy_import/version'

DEBUG = true
puts "##{__LINE__} StalnoyRules included..." if DEBUG
class StalnoyRules

  def self.rules_parse (ruls,context,flag=nil)
    flag ||= false

    if ruls != nil then
      parsed_ruls = JSON.parse(ruls)
      splited_ruls = parsed_ruls[context].split("|")
      flag = splited_ruls[1]
      splited_ruls_array = splited_ruls[0].split(",")
      if flag == true then
        return "Ruls: #{ splited_ruls_array.join(',')  } Flag TRUE"
      else
        ruls_array = Array.new()
        t = splited_ruls_array.each do |e|
          ruls_hash = Hash.new()
          v = e.split(":")
          ruls_hash[:operator] = v[0]
          ruls_hash[:value] = v[1]
          ruls_array << ruls_hash
        end
        print "##{__LINE__.to_s} " if DEBUG
        puts ruls_array if DEBUG
        puts "Ruls: #{ splited_ruls_array.join(',')  } Flag #{flag.to_s} \n" if DEBUG
        return ruls_array
      end
    else
      return  100 # INFO: code 100 means ruls is nil

    end
  end

  def self.dunamic_rule (operator, condition, val)
    print "##{__LINE__.to_s} " if DEBUG
    puts "\n Operator: #{operator.inspect} \n Condition: #{condition.inspect}  \n Condition class: #{condition.class}  \n Value class: #{val.class} \n Value: #{val.inspect}" if DEBUG
    # NOTE: dia?size=all error fix need && error available <,>,<=,>= n wft///



    if condition.to_i == 0 && val.to_i == 0 && condition != "0" && val != nil
      t = ((condition.to_s == "nil")? "" : condition).method(operator.to_s)
      e = t.call((val == "nil")? nil : val.strip)
    elsif val == nil && condition != "0"
      t = ((condition.to_s == "nil")? nil : condition).method(operator.to_s)
      e = t.call(val)
    else
      t = ((condition.to_s == "nil")? nil : condition.to_f).method(operator.to_s)
      e = t.call((val == "nil")? 0 : val.to_f)
    end
    # puts "Value  #{val.class}"  if DEBUG
    puts " Return #{e}"  if DEBUG
    return e

  end

  def self.bool_and (arry,val)
    if arry != 100 and arry != nil and arry[0][:operator] != "nil"  then
      print "##{__LINE__.to_s} " if DEBUG
      puts "#bool_and \n"  if DEBUG
      #puts arry.inspect  if DEBUG
      flag = true
      arry.each do |a|
        if !StalnoyRules.dunamic_rule(a[:operator],a[:value],val) then
          flag = false
          break
        end
      end
      return flag
    else
      print "##{__LINE__.to_s} " if DEBUG
      puts "#bool_and #exit_code: 100"  if DEBUG

      return false
    end
  end

  def self.bool_or (arry,val)
    print "##{__LINE__.to_s} " if DEBUG
    puts arry.inspect  if DEBUG

    if arry != 100 and arry != nil and arry[0][:operator] != "nil"  then
      print "##{__LINE__.to_s} " if DEBUG
      puts "#bool_or"  if DEBUG

      flag = false
      arry.each do |a|

        if StalnoyRules.dunamic_rule(a[:operator],a[:value],val) then
          flag = true
          break
        end

      end
      return flag
    else
      print "##{__LINE__.to_s} " if DEBUG
      puts "#bool_and #exit_code: 100"  if DEBUG

      return false
    end
  end



end
