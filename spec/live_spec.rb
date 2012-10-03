require 'spec_helper'

describe "Live tests", :live => true do
  if ENV['POSLAVU_DATANAME'] && ENV['POSLAVU_KEY'] && ENV['POSLAVU_TOKEN']
    before(:all) { WebMock.allow_net_connect! }
    after(:all) { WebMock.disable_net_connect! }
    let!(:client) { POSLavu::Client.new(ENV['POSLAVU_DATANAME'], ENV['POSLAVU_TOKEN'], ENV['POSLAVU_KEY']) }
    subject { client }
    
    describe("tables") do
      let(:response) { client.table(table).page(1,1).to_a }
      subject { response }
      
      describe("locations") do
        let(:table) { 'locations' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          it { should be_kind_of(POSLavu::Row) }
          its(:keys) { should eq [:id, :title, :address, :city, :state, :zip, :phone, :website, :manager, :taxrate, :menu_id, :ag1, :ag2, :PINwait, :integrateCC, :seat_numbers, :PINwaitM, :country, :monitary_symbol, :left_or_right, :gratuity_label, :auto_send_at_checkout, :allow_resend, :lock_orders, :lock_order_override, :exit_after_save, :exit_after_send, :exit_after_print_check, :exit_after_checkout, :exit_after_void, :admin_PIN_discount, :admin_PIN_void, :lock_net_path, :tab_view, :tabs_and_tables, :hide_tabs, :allow_tab_view_toggle, :display_forced_modifier_prices, :component_package, :ask4email_at_checkout, :component_package2, :allow_custom_items, :default_receipt_print, :product_level, :exit_order_after_save, :exit_order_after_send, :exit_order_after_print_check, :use_direct_printing, :debug_mode, :allow_deposits, :cc_signatures, :gateway, :cc_transtype, :admin_PIN_terminal_set, :admin_PIN_till_report, :ml_type, :ml_un, :ml_pw, :ml_listid, :disable_decimal, :individual_cc_receipts, :server_manage_tips, :day_start_end_time, :require_cvn, :display_order_sent_in_ipod, :print_forced_mods_on_receipt, :print_optional_mods_on_receipt, :return_after_add_item_on_ipod, :kitchen_ticket_font_size, :receipt_font_size, :modifiers_in_red, :market_type, :allow_debug_menu, :customer_cc_receipt, :verify_swipe_amount, :itemize_payments_on_receipt, :debug_console, :allow_cc_returns, :allow_voice_auth, :allow_partial_auth, :allow_signature_tip, :mute_register_bell, :group_equivalent_items, :cc_signatures_ipod, :string_encoding, :tax_inclusion, :rounding_factor, :round_up_or_down, :tax_auto_gratuity, :level_to_open_register, :append_cct_details, :html_email_receipts, :verify_remaining_payment, :multiple_quantities_in_red, :verify_quickpay, :use_language_pack, :print_item_notes_on_receipt, :verify_entered_payment, :other_transactions_open_drawer, :credit_transactions_open_drawer, :allow_to_rate, :gateway_debug, :level_to_open_register_at_checkout, :ask_for_guest_count, :level_to_edit_sent_items, :default_dining_room_background, :admin_PIN_void_payments, :admin_PIN_refund, :order_pad_font, :email, :raster_mode_font_size1, :raster_mode_font_size2, :print_logo_on_receipts, :allow_tax_exempt, :level_to_grant_tax_exempt, :timezone, :clockin_overlay, :item_icon_color, :component_package3, :save_device_console_log, :order_pad_font_ipod, :default_preauth_amount, :decimal_char, :thousands_char, :get_card_info, :bypass_checkout_message, :hide_item_titles, :allow_RFID, :display_seat_course_icons, :cash_transactions_open_drawer, :component_package_code, :vf_enrollment_id] }
        }
      end
      
      describe("orders") do
        let(:table) { 'orders' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          it { should be_kind_of(POSLavu::Row) }
          its(:keys) { should eq [:id, :order_id, :location, :location_id, :opened, :closed, :subtotal, :taxrate, :tax, :total, :server, :server_id, :tablename, :send_status, :discount, :discount_sh, :gratuity, :gratuity_percent, :card_gratuity, :cash_paid, :card_paid, :gift_certificate, :change_amount, :reopen_refund, :void, :cashier, :cashier_id, :auth_by, :auth_by_id, :guests, :email, :permission, :check_has_printed, :no_of_checks, :card_desc, :transaction_id, :multiple_tax_rates, :tab, :original_id, :deposit_status, :register, :refunded, :refund_notes, :refunded_cc, :refund_notes_cc, :refunded_by, :refunded_by_cc, :cash_tip, :discount_value, :reopened_datetime, :discount_type, :deposit_amount, :subtotal_without_deposit, :togo_status, :togo_phone, :togo_time, :cash_applied, :reopen_datetime, :rounding_amount, :auto_gratuity_is_taxed, :discount_id, :refunded_gc, :register_name, :opening_device, :closing_device, :alt_paid, :alt_refunded, :last_course_sent, :tax_exempt, :reclosed_datetime, :reopening_device, :reclosing_device, :exemption_id, :exemption_name, :recloser, :recloser_id, :void_reason, :alt_tablename, :checked_out, :idiscount_amount, :past_names, :itax, :togo_name, :merges, :active_device, :tabname, :last_modified, :last_mod_device, :discount_info, :last_mod_register_name, :force_closed] }
        }
      end
      
      describe("order_contents") do
        let(:table) { 'order_contents' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :loc_id, :order_id, :item, :price, :quantity, :options, :special, :modify_price, :print, :check, :seat, :item_id, :printer, :apply_taxrate, :custom_taxrate, :modifier_list_id, :forced_modifier_group_id, :forced_modifiers_price, :course, :print_order, :open_item, :subtotal, :allow_deposit, :deposit_info, :discount_amount, :discount_value, :discount_type, :after_discount, :subtotal_with_mods, :tax_amount, :notes, :total_with_tax, :itax_rate, :itax, :tax_rate1, :tax1, :tax_rate2, :tax2, :tax_rate3, :tax3, :tax_subtotal1, :tax_subtotal2, :tax_subtotal3, :after_gratuity, :void, :discount_id, :server_time, :device_time, :idiscount_id, :idiscount_sh, :idiscount_value, :idiscount_type, :idiscount_amount, :split_factor, :hidden_data1, :hidden_data2, :hidden_data3, :hidden_data4, :tax_inclusion, :tax_name1, :tax_name2, :tax_name3, :sent, :tax_exempt, :exemption_id, :exemption_name, :itax_name, :checked_out, :hidden_data5, :hidden_data6, :price_override, :original_price, :override_id, :auto_saved, :idiscount_info, :category_id] }
        }
      end
      
      describe("order_payments") do
        let(:table) { 'order_payments' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :order_id, :check, :amount, :card_desc, :transaction_id, :refunded, :refund_notes, :refunded_by, :refund_pnref, :tip_amount, :auth, :loc_id, :processed, :auth_code, :card_type, :datetime, :pay_type, :voided, :void_notes, :voided_by, :void_pnref, :register, :got_response, :transtype, :split_tender_id, :temp_data, :change, :total_collected, :record_no, :server_name, :action, :ref_data, :process_data, :voice_auth, :server_id, :preauth_id, :tip_for_id, :swipe_grade, :batch_no, :register_name, :pay_type_id, :first_four, :mpshc_pid, :server_time, :info, :signature, :info_label, :for_deposit, :more_info, :customer_id, :is_deposit, :device_udid, :internal_id] }
        }
      end
      
      describe("menu_groups") do
        let(:table) { 'menu_groups' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :menu_id, :group_name, :orderby] }
        }
      end
      
      describe("menu_categories") do
        let(:table) { 'menu_categories' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :menu_id, :group_id, :name, :image, :description, :active, :print, :last_modified_date, :printer, :modifier_list_id, :apply_taxrate, :custom_taxrate, :forced_modifier_group_id, :print_order, :super_group_id, :tax_inclusion, :ltg_display] }
        }
      end
      
      describe("menu_items") do
        let(:table) { 'menu_items' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :category_id, :menu_id, :name, :price, :description, :image, :options1, :options2, :options3, :active, :print, :quick_item, :last_modified_date, :printer, :apply_taxrate, :custom_taxrate, :modifier_list_id, :forced_modifier_group_id, :image2, :image3, :misc_content, :ingredients, :open_item, :hidden_value, :hidden_value2, :allow_deposit, :UPC, :hidden_value3, :inv_count, :show_in_app, :super_group_id, :tax_inclusion, :ltg_display] }
        }
      end
      
      describe("tables") do
        let(:table) { 'tables' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :loc_id, :coord_x, :coord_y, :shapes, :widths, :heights, :names, :title, :rotate, :centerX, :centerY] }
        }
      end
      
      describe("clock_punches") do
        let(:table) { 'clock_punches' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :location, :location_id, :punch_type, :server, :server_id, :time, :hours, :punched_out, :time_out, :server_time, :server_time_out, :punch_id, :udid_in, :udid_out, :ip_in, :ip_out, :notes] }
        }
      end
      
      describe("modifiers") do
        let(:table) { 'modifiers' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:title, :cost, :category, :id, :ingredients] }
        }
      end
      
      describe("modifiers_used") do
        let(:table) { 'modifiers_used' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :loc_id, :order_id, :mod_id, :qty, :type, :row, :cost, :unit_cost] }
        }
      end
      
      describe("forced_modifiers") do
        let(:table) { 'forced_modifiers' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:title, :cost, :list_id, :id, :detour, :extra, :extra2, :ingredients, :extra3, :extra4, :extra5] }
        }
      end
      
      describe("ingredients") do
        let(:table) { 'ingredients' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:title, :qty, :unit, :low, :high, :id, :category, :cost, :loc_id] }
        }
      end
      
      describe("ingredient_categories") do
        let(:table) { 'ingredient_categories' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:title, :description, :id, :loc_id] }
        }
      end
      
      describe("ingredient_usage") do
        let(:table) { 'ingredient_usage' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:ts, :date, :orderid, :itemid, :ingredientid, :qty, :id, :loc_id, :server_time, :cost, :content_id] }
        }
      end
      
      describe("users") do
        let(:table) { 'users' }
        it { should_not be_empty }
      
        describe("#first") {
          subject { response.first }
          its(:keys) { should eq [:id, :company_code, :username, :f_name, :l_name, :email, :access_level, :quick_serve, :loc_id, :service_type, :address, :phone, :mobile, :role_id, :deleted_date, :created_date] }
        }
      end
    end
    
  else
    it("API credentials") {
      pending "none provided; see README.md"
    }
  end
end
