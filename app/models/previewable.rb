module Previewable
  SHORT_TITLE_LENGTH = 30

  def preview(string, length)
    return if string.nil?

    if string.length > length
      "#{string[0..(length-4)]}..."
    else
      string
    end
  end
end
