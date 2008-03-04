
module Redcar
  class Keymap
    extend FreeBASE::StandardPlugin

    def self.load(plugin)
      plugin.transition(FreeBASE::LOADED)
    end
    
    def self.start(plugin)
      @obj_keymaps = Hash.new {|obj,key| obj[key] = [] }
      plugin.transition(FreeBASE::RUNNING)
    end
    
    def self.process(gdk_eventkey)
      kv = gdk_eventkey.keyval
      ks = gdk_eventkey.state - Gdk::Window::MOD2_MASK
      ks = ks - Gdk::Window::MOD4_MASK
      key = Gtk::Accelerator.get_label(kv, ks)
      unless key[-2..-1] == " L" or key[-2..-1] == " R"
        bits = key.split("+")
        ctrl = (bits.include?("Ctrl")  ? 1 : 0)
        alt  = (bits.include?("Alt")   ? 1 : 0)
        supr = (bits.include?("Super") ? 1 : 0)
        shift = (bits.include?("Shift") ? 1 : 0)
        key = "Ctrl+"*ctrl + "Super+"*supr + "Alt+"*alt + "Shift+"*shift+ bits.last
        puts key
        execute_key(key)
      end
    end
    
    def self.clear_keymaps_from_object(obj)
      @obj_keymaps.delete obj
    end
    
    # Use to register a key. key_path should look like "Global/Ctrl+G"
    # which represents adding the key Ctrl+G to the Global keymap. 
    # Other examples:
    #   "EditTab/Ctrl+Super+R"
    #   "Snippet/Ctrl+H"
    def self.register_key(key_path, command)
      bus("/redcar/keymaps/#{key_path}").data = command
    end
    
    
    # Pushes a keymap (with keymap_path eg "Global" or "EditView/Snippet") 
    # onto a particular object. E.g. self.push_onto(Redcar::Window, 
    # "MyKeyMap")
    def self.push_onto(obj, keymap_path)
      @obj_keymaps[obj] << keymap_path
    end
    
    # Use to execute a key. key_name should be a string like "Ctrl+G".
    # Execute key will scan the keymap stacks for the first instance of
    # this key then execute the appropriate command.
    # The keymap stacks are processed in this order:
    #    current gtk widget instance
    #    current gtk widget class
    #    current tab instance
    #    current tab class
    #    current window instance
    #    current window class
    def self.execute_key(key_name)
      stack_objects = [win.focussed_gtk_widget,
                       win.focussed_gtk_widget.class,
                       win.focussed_tab, 
                       win.focussed_tab.class, 
                       win,
                       win.class]
      stack_objects.each do |stack_object|
        if stack_object
          @obj_keymaps[stack_object].reverse.each do |keymap_path|
            return if execute_key_on_keymap(key_name, keymap_path)
          end
        end
      end
    end
    
    def self.execute_key_on_keymap(key_name, keymap_path)
      if com = bus("/redcar/keymaps/#{keymap_path}/#{key_name}").data
        com.execute
      end
    end
  end
end
