require './global_hooks.rb'

class Card

  attr_reader :id, :attributes, :type

  def initialize(id:, type: nil, global_hooks: nil)
    @id = id
    @type = type
    @events = Hash.new
    @attributes = Hash.new
    @pre = Hash.new
    @post = Hash.new
    @global_hooks = global_hooks

    on(:transfer, lambda{ |args| return args.merge({ transfer: true }) })
  end

  def on(event_name, call_back)
    @events[event_name] = call_back
  end


  def trigger_event(event_name, arguments = {})

    arguments[:card] = self

    global_pre = {}
    global_pre = @global_hooks.merge_all(:pre, event_name: event_name, arguments: arguments) if !@global_hooks.nil?

    scope_pre = {}
    scope_pre = @pre[event_name].call(arguments) if @pre.has_key?(event_name)

    return false if global_pre == false
    return false if scope_pre == false

    args = {}
    args = args.merge(global_pre) if global_pre.is_a?(Hash)
    args = args.merge(scope_pre) if scope_pre.is_a?(Hash)
    args = args.merge(arguments) if arguments.is_a?(Hash)

    arguments = args

    result = {}
    result = @events[event_name].call(arguments) if @events.has_key?(event_name)

    @global_hooks.merge_all(:post, event_name: event_name, arguments: arguments) if !@global_hooks.nil?
    @post[event_name].call(arguments) if @post.has_key?(event_name)

    return result
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
