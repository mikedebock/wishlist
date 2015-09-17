module Wishlist
  class Member < Wishlist::Base
    
    def initialize(client, options = {})
      super
      @endpoint = '/members'
    end

    # GET /members
    def all
      page = agent.get path
      JSON.parse(page.body)
    end

    # GET /members/{member_id}
    def find(member_id)
      page = agent.get path(member_id)
      JSON.parse(page.body)
    end

    def find_by_email(email)
      members = self.all
      if members["members"].count > 0 && members["members"]["member"].count > 0
        member = members["members"]["member"].detect{|m| m["user_email"] == email }
      end
      
      if member and member.has_key?('id')
        page = agent.get path(member["id"])
        return JSON.parse(page.body)
      else
        return nil
      end
    end

    def find_by_user_login(user_login)
      members = self.all
      if members["members"].count > 0 && members["members"]["member"].count > 0
        member = members["members"]["member"].detect{|m| m["user_login"] == user_login }
      end
      
      if member and member.has_key?('id')
        page = agent.get path(member["id"])
        return JSON.parse(page.body)
      else
        return nil
      end
    end

    # POST /members
    def create(data = {})
      [:user_login, :user_email].each do |attribute|
        raise "`#{attribute}` is required." unless (data.has_key?(attribute) || data.has_key?(attribute.to_s))
      end
      agent.post path, data
    end

    # PUT /members/{member_id}
    def update(member_id, data = {})
      agent.put path(member_id), data, { 'Content-Length' => data.to_query.length }
    end

    # DELETE /members/{member_id}
    def delete(member_id)
      agent.delete path(member_id)
    end
    
    
    def path(member_id = nil)
      if member_id
        return "#{client.url}#{endpoint}/#{member_id}"
      else
        return "#{client.url}#{endpoint}"
      end
    end
    
  end
end
