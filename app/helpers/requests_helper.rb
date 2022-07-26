module RequestsHelper

  def comm_email(request)
    if @request.requester_email == nil
      return @request.requester.email
    else
      return @request.requester_email
    end
  end

  def is_request_active(request)
    [Request::OPEN, Request::INPROGRESS, Request::INCOMPLETE].include?(request.status)
  end

  def open_request_needs_attention_css?(r)
    if is_request_active(r)
      if 4.weeks.ago > r.created_at
        return "needs_attention_now"
      elsif 2.weeks.ago > r.created_at
        return "needs_attention_soon"
      end
    end
  end
end
