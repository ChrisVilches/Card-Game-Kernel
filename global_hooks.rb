class GlobalHooks

  attr_reader :hooks

  def initialize
    @unique_id = 1
    @hooks = {
      pre: {},
      transfer: {}
    }
  end

  def append_hook(pre_post, event_name:, fn:, card_owner_id: nil)

    id = @unique_id
    @unique_id = @unique_id + 1
    ensure_hook(pre_post, event_name)
    @hooks[pre_post][event_name] << {
      card_owner_id: card_owner_id,
      fn: fn,
      hook_id: id
    }

    return id

  end

  def remove_by_card_id(pre_post, event_name:, card_owner_id:)
    remove_index = nil
    @hooks[pre_post][event_name].each_with_index do |x, i|

      if(x[:card_owner_id] == card_owner_id)
        remove_index = i
        break
      end

    end
    return if remove_index.nil?
    @hooks[pre_post][event_name].delete_at remove_index
  end


  def merge_all(pre_post, event_name:, arguments:)

    results = {}

    ensure_hook pre_post, event_name

    @hooks[pre_post][event_name].each do |hook|

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



  private
  def is_already_added(fn)
  end

  def ensure_hook(pre_post, event_name)
    @hooks[pre_post] = {} if !@hooks.has_key?(pre_post)
    @hooks[pre_post][event_name] = [] if !@hooks[pre_post].has_key?(event_name)
  end


end
