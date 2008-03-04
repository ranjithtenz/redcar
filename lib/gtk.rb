
require 'gtk2'

module Gtk
  class Widget
    alias old_initialize initialize
    def initialize
      old_initialize
      signal_connect('move_focus') do |_, _, _|
        p :grab_notify
        false
      end
    end
  end
  
  class ImageMenuItem
    # Helper to create a Gtk::ImageMenuItem from a string
    # corresponding to a Gtk::Stock constant, and a string
    # of text for the item label.
    # e.g. stock_name = "FILE" -> Gtk::Stock::FILE.
    def self.create(stock_name, text)
      gtk_menuitem = Gtk::ImageMenuItem.new(text)
      stock = Gtk::Stock.const_get(stock_name)
      iconimg = Gtk::Image.new(stock, 
                               Gtk::IconSize::MENU)
      gtk_menuitem.image = iconimg
      gtk_menuitem
    end
  end
  
  class MenuItem
    attr_accessor :redcar_position
  end

  class Notebook
    # Returns the child widget of the current page.
    def page_child
      get_nth_page page
    end
  end
  
  # A simple notebook "label" (HBox container) with a text label and 
  # a close button.
  class NotebookLabel < HBox
    type_register
    
    # Creates a new notebook label labeled with the text *str*.
    def initialize(tab, str='', &on_close)
      super()
      self.homogeneous = false
      self.spacing = 4
      
      @box = Gtk::HBox.new
      
      @label = Gtk::Label.new(str)
      
      @button = Gtk::Button.new
      @button.set_border_width(0)
      @button.set_size_request(22, 22)
      @button.set_relief(Gtk::RELIEF_NONE)
      
      image = Gtk::Image.new
      image.set(:'gtk-close', Gtk::IconSize::MENU)
      @button.add(image)
      
      pack_start(@box)
      
      @box.pack_start(@label, true, false, 0)
      @box.pack_start(@button, false, false, 0)
      
      @button.signal_connect('clicked') do |widget, event|
        on_close.call if on_close
      end
      show_all
    end
    
    attr_reader :label, :button
    
    def make_horizontal
      unless @box.is_a? Gtk::HBox
        self.remove @box
        @box.remove @label
        @box.remove @button
        @box = Gtk::HBox.new
        @box.pack_start(@label, true, false, 0)
        @box.pack_start(@button, false, false, 0)
        pack_start @box
        @box.show
      end
    end
      
    def make_vertical
      unless @box.is_a? Gtk::VBox
        self.remove @box
        @box.remove @label
        @box.remove @button
        @box = Gtk::VBox.new
        @box.pack_start(@label, true, false, 0)
          @box.pack_start(@button, false, false, 0)
        pack_start @box
        @box.show
      end
    end
    
    def text
      @label.text
    end
    
    def text=(t)
      @label.text = t
    end
  end
end