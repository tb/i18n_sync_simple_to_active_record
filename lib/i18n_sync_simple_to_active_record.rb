module I18nSyncSimpleToActiveRecord

  def self.sync
    clean
    load
  end

  def self.clean
    I18n.backend = I18n::Backend::ActiveRecord.new
    I18n::Backend::ActiveRecord::Translation.destroy_all
  end

  def self.load
    I18n.backend = I18n::Backend::Simple.new
    available_locales = I18n.available_locales.collect {|l| l.to_sym}
    translations = {}
    counters = { :total => {}, :loaded => {} }
    
    available_locales.each do |locale|
      translations[locale] = translations_key_values( I18n.backend.send(:translations)[locale].clone )
      counters[:total][locale] = translations[locale].size
      counters[:loaded][locale] = 0
    end

    puts "Available locales: #{available_locales.join(', ')}"

    I18n.backend = I18n::Backend::ActiveRecord.new

    available_locales.each do |locale|
      translations[locale].each do |k,v|
        unless I18n::Backend::ActiveRecord::Translation.find_by_key(k)
          translation = v
          k.split(".").reverse.each do |namespace|
            translation = { namespace => translation }
          end
          I18n.backend.store_translations locale, translation

          puts "I18n.backend.store_translations :#{locale}, #{translation.inspect}"
          counters[:loaded][locale] += 1
        end
      end
    end

    puts "Locales total counters:  #{counters[:total].inspect}"
    puts "Locales loaded counters: #{counters[:loaded].inspect}"
  end

  def self.translations_key_values(translations, key=nil, value=nil)
    result = {}
    translations.each do |k, v|
       new_key = key.nil? ? k.to_s : key+".#{k}"
       if v.class == Hash
         result.merge!(translations_key_values(v, new_key))
       else
         result.merge!({ new_key => v })
       end
    end
    result
  end

end