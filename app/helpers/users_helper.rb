module UsersHelper

  # Returns the Gravatar for the given user.
  # Uses keyword argument (size) with a main positional argument (user)
  def gravatar_for(user, size: 80)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    return image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

end
