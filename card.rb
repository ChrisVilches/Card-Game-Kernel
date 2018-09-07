class Card

  attr_reader :id, :attributes, :type

  def initialize(id:, type: nil, global_state: nil)
    @id = id
    @type = type
    @events = Hash.new
    @attributes = Hash.new
    @pre = Hash.new
    @post = Hash.new
    @global_state = global_state

    @global_state = {} if @global_state.nil?

    on(:transfer, lambda{ |args| return args })
  end

  def on(event_name, call_back)
    @events[event_name] = call_back
  end

  def merge_all_global(array, arguments)

    return true if array == nil

    results = {}

    array.each do |hook|

      res = hook[:fn].call(arguments)
      if res == false
        return false
      end

      if res.is_a?(Hash)
        results = results.merge(res)
      end

    end


    return results
  end

  def trigger_event(event_name, arguments = {})

    require 'pp'

    global_pre = {}

    begin
      if !@global_state[:pre][event_name].is_a?(Array)
        @global_state[:pre][event_name] = []
      end
      rescue
    end

    global_pre = merge_all_global(@global_state[:pre][event_name], arguments) if @global_state.has_key?(:pre) && @global_state[:pre].has_key?(event_name)

    scope_pre = {}
    scope_pre = @pre[event_name].call(arguments) if @pre.has_key?(event_name)

    return nil if global_pre == false
    return nil if scope_pre == false

    args = {}
    args = args.merge(global_pre) if global_pre.is_a?(Hash)
    args = args.merge(scope_pre) if scope_pre.is_a?(Hash)
    args = args.merge(arguments) if arguments.is_a?(Hash)

    arguments = args

    result = @events[event_name].call(arguments)


    merge_all_global(@global_state[:post][event_name], arguments) if @global_state.has_key?(:post) && @global_state[:post].has_key?(event_name)
    @post[event_name].call(arguments) if @post.has_key?(event_name)

    return result.merge({ transfer: true })
  end

  def set_state
  end

  def set_attributes(attrs)
    @attributes = @attributes.merge(attrs)
  end

  def to_s
    @id
  end

end
