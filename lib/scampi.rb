# Scampi -- small RSpec clone with TAP output.
#
# Forked from Bacon by Christian Neukirchen.
# "Truth will sooner come out from error than from confusion." ---Francis Bacon

# Copyright (C) 2007, 2008, 2012 Christian Neukirchen <purl.org/net/chneukirchen>
#
# Scampi is freely distributable under the terms of an MIT-style license.
# See COPYING or http://www.opensource.org/licenses/mit-license.php.

require_relative 'scampi/version'
require 'colorize_extended'

module Scampi
  Counter = Hash.new(0)
  ErrorLog = "".dup
  Shared = Hash.new { |_, name|
    raise NameError, "no such context: #{name.inspect}"
  }

  RestrictName    = //  unless defined? RestrictName
  RestrictContext = //  unless defined? RestrictContext

  Backtraces = true  unless defined? Backtraces

  @queue = []
  @ran = false

  def self.queue
    @queue
  end

  def self.run
    return if @ran
    @ran = true

    # Register: evaluate all describe blocks to discover specs
    @queue.each { |item| item.register if item.is_a?(Context) }

    # TAP version + plan
    puts "TAP version 14"
    puts "1..#{@queue.size}"

    # Execute: contexts become subtests, raw specs become flat lines
    @queue.each_with_index do |item, i|
      n = i + 1
      if item.is_a?(Context)
        passed = item.execute(0)
        if passed
          puts "#{"ok".green} #{n} - #{item.name}"
        else
          puts "#{"not ok".red} #{n} - #{item.name}"
        end
      else
        _, description, block = item
        Counter[:specifications] += 1
        passed = run_bare_spec(description, block, n)
      end
    end

    # Summary comment
    tests, assertions, failures, errors =
      Counter.values_at(:specifications, :requirements, :failed, :errors)
    puts "# #{tests} tests, #{assertions} assertions, #{failures} failures, #{errors} errors"
  end

  def self.summary_on_exit
    return  if Counter[:installed_summary] > 0
    @timer = Time.now
    at_exit {
      run
      if $!
        raise $!
      elsif Counter[:errors] + Counter[:failed] > 0
        exit 1
      end
    }
    Counter[:installed_summary] += 1
  end
  class << self; alias summary_at_exit summary_on_exit; end

  # TAP output

  def self.handle_requirement(description, indent = 0, local_n = 1)
    ErrorLog.replace ""
    error = yield
    prefix = "    " * indent
    if error.empty?
      puts "#{prefix}#{"ok".green} #{local_n} - #{description}"
      true
    else
      puts "#{prefix}#{"not ok".red} #{local_n} - #{description}: #{error}"
      puts ErrorLog.strip.gsub(/^/, "#{prefix}# ")  if Backtraces
      false
    end
  end

  def self.run_bare_spec(description, block, n)
    handle_requirement(description, 0, n) do
      begin
        Counter[:depth] += 1
        rescued = false
        begin
          prev_req = Counter[:requirements]
          block.call
        rescue Object => e
          rescued = true
          raise e
        ensure
          if Counter[:requirements] == prev_req and not rescued
            raise Error.new(:missing, "empty specification: #{description}")
          end
        end
      rescue SystemExit, Interrupt
        raise
      rescue Object => e
        ErrorLog << "#{e.class}: #{e.message}\n"
        e.backtrace.find_all { |line| line !~ /bin\/scampi|\/scampi\.rb:\d+/ }.
          each_with_index { |line, i|
          ErrorLog << "\t#{line}#{i==0 ? ": #{description}" : ""}\n"
        }
        ErrorLog << "\n"

        if e.kind_of? Error
          Counter[e.count_as] += 1
          e.count_as.to_s.upcase
        else
          Counter[:errors] += 1
          "ERROR: #{e.class}"
        end
      else
        ""
      ensure
        Counter[:depth] -= 1
      end
    end
  end
end

require_relative 'scampi/error'
require_relative 'scampi/context'
require_relative 'scampi/should'
require_relative 'scampi/monkey_patches'
require_relative 'scampi/kernel_ext'
