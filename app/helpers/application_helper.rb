# coding: utf-8
module ApplicationHelper
  def my_devise_error_messages!
    return "" if resource.errors.empty?
    messages = ""
    if !resource.errors.empty?
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    end

    messages = messages
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation" class="alert alert-danger">
    <label>#{sentence}</label>
    <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-warning"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def set_current_register_step(step_name)
    @current_step == step_name ? 'active' : ''
  end

  def payment_methods_for_select
    options = []
    Payment::PAYMENT_METHODS.each_with_index do |p_m, index|
      options << [p_m.capitalize, index]
    end
    options
  end

  def bookmarkers_for_select(platforms)
    options = []
    platforms.each do |pf|
      options << [pf.name.titleize, pf.code]
    end
    options
  end

  def sports_for_select(sports)
    options = []
    sports.each do |sp|
      options << [sp.name.titleize, sp.code]
    end
    options
  end

  def events_for_select(events)
    options = []
    events.each do |event|
      options << [event.name, event.name]
    end
    options
  end

  def bet_types_for_select(bet_types, selected_sport_code = nil)

    options = []
    bet_types.each do |bet_type|
      attrs = [
          bet_type.name.titleize, bet_type.code,
          'data-sport-code' => bet_type.sport_code
      ]
      if bet_type.has_line?
        attrs << {'data-has-line' => true}
      end

      # Hide the bet types not belong to selected sport
      if selected_sport_code.present? && bet_type.sport_code != selected_sport_code
        attrs << {class: 'select2-offscreen'}
      end
      options << attrs
    end
    options
  end

  def ranking_ranges_for_select
    options = []
    TipsterStatistics::RANKING_RANGES.each do |range|
      options << [
          I18n.t("tipster.ranking.ranges.#{range}").titleize,
          range,
          'data-url' => tipster_path(ranking: range),
          selected: current_ranking_range_param == range
      ]
    end
    options
  end

  def class_for_sport_filter(sport, current_sport = nil)
    current_sport ||= query_params[:sport]
    current_sport = 'all' if current_sport.nil?
    current_sport == sport ? 'current active disabled' : ''
  end

  def class_for_date_filter(date)
    current_date = query_params[:date]
    current_date = 'today' if current_date.nil?
    current_date == date ? 'disabled text-muted' : ''
  end

  def query_params
    request.query_parameters
  end

  def current_date_param
    query_params[:date] ||= 'Today'
  end

  def current_sport_param
    query_params[:sport]
  end

  # Detemine the my_account path for two resources: subscriber or tipster
  def update_profile_path_for(user)
    if user.is_a? Tipster
      backoffice_update_profile_path
    elsif user.is_a? Subscriber
      update_profile_path
    elsif user.is_a? Admin
      admin_update_profile_path
    end
  end

  # Detemine the change_password path for two resources: subscriber or tipster
  def change_password_path_for(user)
    if user.is_a? Tipster
      backoffice_change_password_path
    elsif user.is_a? Subscriber
      change_password_path
    elsif user.is_a? Admin
      admin_change_password_path
    end
  end

  # Detemine the change_avatar path for two resources: subscriber or tipster
  def change_avatar_path_for(user)
    if user.is_a? Tipster
      backoffice_change_avatar_path
    elsif user.is_a? Subscriber
      change_avatar_path
    end
  end

  def crop_avatar_path_for(user)
    if user.is_a? Tipster
      backoffice_crop_avatar_path
    elsif user.is_a? Subscriber
      crop_avatar_path
    end
  end

  # This method nolonger used because we only sort by profit or yield with DESC direction
  #def sort_params_for(field)
  #  current_sort_param = params[:sort]
  #  sort_direction = ''
  #
  #  if current_sort_param.present?
  #    sort_direction = current_sort_param.split('_').last
  #    sort_direction = (sort_direction == 'desc') ? 'asc' : 'desc'
  #  else
  #    sort_direction = SortingInfo::INCREASE
  #  end
  #  query_params.merge(sort: "#{field}_#{sort_direction}")
  #end

  def date_filter_param(date)
    query_params.merge(date: date)
  end

  def profit_img_chart_url_for(data, options = {})
    default_options = {
        size: '125x40'
    }
    options = default_options.merge(options)
    require 'gchart'
    Gchart.line(
        data: data, :encoding => 'extended',
        grid_lines: '16,32,4,0,0,0',
        range_markers: 'B,99999970,0,0,0',
        bg: {
            color: '00000000',
            type: 'gradient'
        },
        graph_bg: {
            type: 'gradient',
            color: '454545,0,121212,1',
            angle: '270'
        },
        line_colors: 'ACC253',
        :size => options[:size],
    )
  end

  def class_for_link_to_change_lang(lang)
    lang = lang.to_sym
    I18n.locale == lang ? 'current' : ''
  end

  def set_current_menu(menu_name, current)
    menu_name == current ? 'current' : nil
  end

  def genders_collection_for_select
    options = []
    options << [I18n.t('user.male'), true]
    options << [I18n.t('user.female'), false]
    options
  end

  def date_range_filter_for_tips
    date_param = query_params[:date]
    if date_param.present?
      begin
        current_date = date_param.to_date
      rescue => e
        current_date = Date.today
      end
    end
    current_date = Date.today if (current_date.nil? || current_date.future?)
    range = []
    tmp_date = current_date
    if current_date.past?
      range << {value: current_date.next_day.to_s, label: '<< Next day'}
    end
    7.times do |i|
      range << {value: tmp_date.to_s, label: tmp_date.strftime("%b %d")}
      tmp_date = tmp_date.prev_day
    end
    range << {value: current_date.prev_day.to_s, label: 'Prev day >>'}
  end

  def current_sort_by_param
    query_params[:sort_by] ||= Tipster::DEFAULT_RANKING_SORT_BY
  end

  def current_ranking_range_param
    query_params[:ranking] ||= TipsterStatistics::DEFAULT_RANKING_RANGE
  end


  def class_for_subscribe_step(step, current_step)
    current_step = current_step || 1
    if step < current_step
      'complete'
    elsif step == current_step
      'current'
    else
      'default'
    end
  end

  def links_for_subscribe_step(step, current_step)
    case step
      when 1
        current_step >= step ? link_to(I18n.t('menu.subscribe.paid.step1'), subscribe_shopping_cart_path) : I18n.t('menu.subscribe.paid.step1')
      when 2
        current_step >= step ? link_to(I18n.t('menu.subscribe.paid.step2'), subscribe_personal_information_path) : I18n.t('menu.subscribe.paid.step2')
      when 3
        current_step >= step ? link_to(I18n.t('menu.subscribe.paid.step3'), subscribe_shared_path) : I18n.t('menu.subscribe.paid.step3')
      when 4
        current_step >= step ? link_to(I18n.t('menu.subscribe.paid.step4'), subscribe_receive_methods_path) : I18n.t('menu.subscribe.paid.step4')
      when 5
        current_step >= step ? link_to(I18n.t('menu.subscribe.paid.step5'), subscribe_payment_path) : I18n.t('menu.subscribe.paid.step5')
    end
  end

  def links_for_subscribe_free_step(step, current_step)
    case step
      when 1
        current_step >= step ? link_to(I18n.t('menu.subscribe.free.step1'), subscribe_personal_information_path) : I18n.t('menu.subscribe.free.step1')
      when 2
        current_step >= step ? link_to(I18n.t('menu.subscribe.free.step2'), subscribe_shared_path) : I18n.t('menu.subscribe.free.step2')
      when 3
        I18n.t('menu.subscribe.free.step3')
    end
  end

  def header_menu_adding(size, tipster, plan)
    case size
      when 0
        if tipster
          "Please choose your Subsctiption"
        elsif plan
          "Please choose your TIPSTERHERO"
        end
      else
        "Your SUPER TipsterHero has been added in your shopping cart"
    end
  end

  def header_menu_adding_popup(cart_size, tipster_first)
    case cart_size
      when 0
        if tipster_first
          {
              left: 'Your SUPER TIPSTERHERO',
              right: 'Your Subscription'

          }
        else
          {
              left: 'Your Subscription',
              right: 'Your SUPPER TIPSTERHERO'
          }
        end
      when 1
        if tipster_first
          {
              left: 'Your SUPER TIPSTERHERO',
              right: 'Your Subscription'

          }
        else
          {
              left: 'Your Subscription',
              right: 'Your SUPPER TIPSTERHERO'
          }
        end
      when 2
        {
            left: 'SECOND TIPSTERHERO',
            right: 'THIRD TIPSTERHERO'
        }
      when 3
        {
            left: 'SECOND TIPSTERHERO',
            right: 'THIRD TIPSTERHERO'
        }
      when 4
        {
            left: 'SECOND TIPSTERHERO',
            right: 'THIRD TIPSTERHERO'
        }
    end
  end

  def flag_class_for_area_id(opta_area_id)
    areas_map = {"1" => "world", "8" => "af", "19" => "au", "23" => "bh", "24" => "BAN", "31" => "bu", "37" => "BRU", "41" => "ca",
                 "49" => "cn", "50" => "TPE", "84" => "GUM", "91" => "HKG", "94" => "IND", "95" => "IDN", "96" => "IRN",
                 "97" => "IRQ", "102" => "JPN", "103" => "JOR", "106" => "PRK", "107" => "KOR", "108" => "KUW", "109" => "KGZ",
                 "110" => "LAO", "112" => "LIB", "119" => "MAC", "123" => "MAS", "124" => "MDV", "131" => "MGL", "135" => "MYA",
                 "137" => "NEP", "147" => "OMA", "148" => "PAK", "149" => "PAL", "154" => "PHI", "158" => "QAT", "164" => "KSA",
                 "170" => "SIN", "177" => "SRI", "186" => "SYR", "189" => "TJK", "191" => "THA", "197" => "TKM", "202" => "UAE",
                 "205" => "UZB", "208" => "VIE", "210" => "YEM", "221" => "EAT", "251" => "NMI", "271" => "MPA", "10" => "ALG",
                 "13" => "ANG", "29" => "BEN", "34" => "BOT", "39" => "BFA", "40" => "BDI", "42" => "CMR", "44" => "CPV", "46" => "CTA",
                 "47" => "CHA", "52" => "CGO", "53" => "COD", "60" => "CIV", "62" => "DJI", "66" => "EGY", "69" => "EQG", "70" => "ERI",
                 "72" => "ETH", "77" => "GAB", "78" => "GAM", "81" => "GHA", "86" => "GUI", "87" => "GNB", "105" => "KEN", "113" => "LES",
                 "114" => "LBR", "115" => "LBY", "121" => "MAD", "122" => "MWI", "125" => "MLI", "127" => "MTN", "128" => "MRI", "133" => "MAR",
                 "134" => "MOZ", "136" => "NAM", "143" => "NIG", "144" => "NGA", "161" => "RWA", "166" => "SEN", "168" => "SEY",
                 "169" => "SLE", "174" => "SOM", "175" => "RSA", "181" => "SUD", "183" => "SWZ", "187" => "STP", "190" => "TAN",
                 "192" => "TOG", "195" => "TUN", "200" => "UGA", "211" => "ZAM", "212" => "ZIM", "220" => "ZAN", "223" => "REU", "232" => "CMO",
                 "255" => "MYT", "256" => "SSD", "14" => "AIA", "15" => "ATG", "18" => "ABW", "22" => "BHS", "25" => "BRB", "28" => "BLZ",
                 "30" => "BMU", "36" => "BVI", "43" => "CAN", "45" => "CYM", "55" => "CRI", "57" => "CUB", "63" => "DMA", "64" => "DOM",
                 "67" => "SLV", "83" => "GRD", "85" => "GTM", "88" => "GUY", "89" => "HTI", "90" => "HND", "101" => "JAM", "129" => "MEX",
                 "132" => "MSR", "139" => "CUR", "142" => "NIC", "150" => "PAN", "157" => "PRI", "178" => "SKN", "179" => "STL", "180" => "SVG",
                 "182" => "SUR", "194" => "TTO", "198" => "TCA", "199" => "USV", "203" => "us", "227" => "GDL", "228" => "SMT", "229" => "MTQ",
                 "230" => "SMA", "231" => "FGU", "259" => "SEU", "260" => "BON", "16" => "ARG", "32" => "BOL", "35" => "br", "48" => "CHL",
                 "51" => "COL", "65" => "ECU", "152" => "PRY", "153" => "PER", "204" => "URY", "207" => "VEN", "11" => "ASM", "54" => "COK",
                 "74" => "FJI", "140" => "NCL", "141" => "NZL", "151" => "PNG", "162" => "WSM", "173" => "SLB", "188" => "TAH", "193" => "TON",
                 "206" => "VUT", "233" => "TVL", "252" => "KIR", "257" => "NIU", "258" => "NAU", "262" => "MIC", "9" => "ALB", "12" => "AND",
                 "17" => "ARM", "20" => "AUT", "21" => "AZE", "26" => "BLR", "27" => "be", "33" => "BIH", "38" => "BGR", "56" => "HRV",
                 "58" => "CYP", "59" => "CZE", "61" => "DNK", "68" => "en", "71" => "EST", "73" => "FRO", "75" => "FIN", "76" => "fr",
                 "79" => "GEO", "80" => "de", "82" => "gr", "92" => "HUN", "93" => "ISL", "98" => "IRL", "99" => "ISR", "100" => "it",
                 "104" => "KAZ", "111" => "LVA", "116" => "LIE", "117" => "LTU", "118" => "LUX", "120" => "MKD", "126" => "MLT",
                 "130" => "MHL", "138" => "nl", "145" => "NIR", "146" => "NOR", "155" => "POL", "156" => "pt", "159" => "ROU",
                 "160" => "ru", "163" => "SMR", "165" => "scotland", "167" => "SCG", "171" => "SVK", "172" => "SVN", "176" => "es",
                 "184" => "SWE", "185" => "CHE", "196" => "tr", "201" => "UKR", "209" => "WAL", "224" => "SER", "225" => "MNE",
                 "226" => "GIB", "235" => "JER", "236" => "IOM", "249" => "KSV", "250" => "GBR", "253" => "MCO", "254" => "GGY",
                 "263" => "VAT", "270" => "TNC", "2" => "", "3" => "", "4" => "", "5" => "", "6" => "", "261" => "PAL", "7" => "eu"}
    "flag-" << areas_map["#{opta_area_id}"].downcase
  end

  def class_for_sport_icon(code)
    "i-#{code}"
  end

  def adding_price_show(price)
    "#{price}  € / month"
  end

  def matches_group_by_for_select
    options = []
    options << ['Date', 'date']
    options << ['Sport', 'date']
    options
  end

  def append_query_param(path, param ={})

  end

  def sport_filter_for_select(sports)
    options = []
    options << ['All', nil]
    sports.each do |sport|
      options << [
          sport.name.titleize,
          sport.code
      ]
    end
    options
  end

  def competition_filter_for_matches(competitions)
    options = []
    options << ['All', nil]
    competitions.each do |compt|
      options << [compt.name.titleize, compt.uid]
    end
    options
  end

  def phone_indicator_for_select
    options = [["+1", "+1 (CA)"], [" +1", "+1 (US)"], ["+7", "+7 (RU)"], [" +7", "+7 (KZ)"], ["+20", "+20 (EG)"], ["+27", "+27 (ZA)"], ["+30", "+30 (GR)"], ["+31", "+31 (NL)"], ["+32", "+32 (BE)"], ["+33", "+33 (FR)"], ["+34", "+34 (ES)"], ["+36", "+36 (HU)"], ["+38", "+38 (YU)"], ["+39", "+39 (IT)"], ["+40", "+40 (RO)"], ["+41", "+41 (CH)"], ["+43", "+43 (AT)"], ["+44", "+44 (GB)"], ["+45", "+45 (DK)"], ["+46", "+46 (SE)"], ["+47", "+47 (NO)"], ["+48", "+48 (PL)"], ["+49", "+49 (DE)"], ["+51", "+51 (PE)"], ["+52", "+52 (MX)"], ["+53", "+53 (CU)"], ["+54", "+54 (AR)"], ["+55", "+55 (BR)"], ["+56", "+56 (CL)"], ["+57", "+57 (CO)"], ["+58", "+58 (VE)"], ["+60", "+60 (MY)"], ["+61", "+61 (AU)"], ["+62", "+62 (ID)"], ["+63", "+63 (PH)"], ["+64", "+64 (NZ)"], ["+65", "+65 (SG)"], ["+66", "+66 (TH)"], ["+81", "+81 (JP)"], ["+82", "+82 (KR)"], ["+84", "+84 (VN)"], ["+86", "+86 (CN)"], ["+90", "+90 (TR)"], ["+91", "+91 (IN)"], ["+92", "+92 (PK)"], ["+93", "+93 (AF)"], ["+94", "+94 (LK)"], ["+95", "+95 (MM)"], ["+98", "+98 (IR)"], ["+212", "+212 (MA)"], ["+213", "+213 (DZ)"], ["+216", "+216 (TN)"], ["+218", "+218 (LY)"], ["+220", "+220 (GM)"], ["+221", "+221 (SN)"], ["+222", "+222 (MR)"], ["+223", "+223 (ML)"], ["+224", "+224 (GN)"], ["+225", "+225 (CI)"], ["+226", "+226 (BF)"], ["+227", "+227 (NE)"], ["+228", "+228 (TG)"], ["+229", "+229 (BJ)"], ["+230", "+230 (MU)"], ["+231", "+231 (LR)"], ["+232", "+232 (SL)"], ["+233", "+233 (GH)"], ["+234", "+234 (NG)"], ["+235", "+235 (TD)"], ["+236", "+236 (CF)"], ["+237", "+237 (CM)"], ["+238", "+238 (CV)"], ["+239", "+239 (ST)"], ["+240", "+240 (GQ)"], ["+241", "+241 (GA)"], ["+242", "+242 (CG)"], ["+243", "+243 (CG)"], ["+244", "+244 (AO)"], ["+245", "+245 (GW)"], ["+246", "+246 (IO)"], ["+247", "+247 (AC)"], ["+248", "+248 (SC)"], ["+249", "+249 (SD)"], ["+250", "+250 (RW)"], ["+251", "+251 (ET)"], ["+252", "+252 (SO)"], ["+253", "+253 (DJ)"], ["+254", "+254 (KE)"], ["+255", "+255 (TZ)"], ["+256", "+256 (UG)"], ["+257", "+257 (BI)"], ["+258", "+258 (MZ)"], ["+260", "+260 (ZM)"], ["+261", "+261 (MG)"], ["+263", "+263 (ZW)"], ["+264", "+264 (NA)"], ["+265", "+265 (MW)"], ["+266", "+266 (LS)"], ["+267", "+267 (BW)"], ["+268", "+268 (SZ)"], ["+269", "+269 (KM)"], ["+290", "+290 (SH)"], ["+291", "+291 (ER)"], ["+297", "+297 (AW)"], ["+298", "+298 (FO)"], ["+299", "+299 (GL)"], ["+350", "+350 (GI)"], ["+351", "+351 (PT)"], ["+352", "+352 (LU)"], ["+353", "+353 (IE)"], ["+354", "+354 (IS)"], ["+355", "+355 (AL)"], ["+356", "+356 (MT)"], ["+357", "+357 (CY)"], ["+358", "+358 (FI)"], ["+359", "+359 (BG)"], ["+370", "+370 (LT)"], ["+371", "+371 (LV)"], ["+372", "+372 (EE)"], ["+373", "+373 (MD)"], ["+374", "+374 (AM)"], ["+375", "+375 (BY)"], ["+376", "+376 (AD)"], ["+377", "+377 (MC)"], ["+378", "+378 (SM)"], ["+379", "+379 (VA)"], ["+380", "+380 (UA)"], ["+381", "+381 (RS)"], ["+382", "+382 (ME)"], ["+385", "+385 (HR)"], ["+386", "+386 (SI)"], ["+387", "+387 (BA)"], ["+389", "+389 (MK)"], ["+420", "+420 (CZ)"], ["+421", "+421 (SK)"], ["+423", "+423 (LI)"], ["+500", "+500 (FK)"], ["+501", "+501 (BZ)"], ["+502", "+502 (GT)"], ["+503", "+503 (SV)"], ["+504", "+504 (HN)"], ["+505", "+505 (NI)"], ["+506", "+506 (CR)"], ["+507", "+507 (PA)"], ["+508", "+508 (PM)"], ["+509", "+509 (HT)"], ["+590", "+590 (GP)"], ["+591", "+591 (BO)"], ["+592", "+592 (GY)"], ["+593", "+593 (EC)"], ["+594", "+594 (GF)"], ["+595", "+595 (PY)"], ["+596", "+596 (MQ)"], ["+597", "+597 (SR)"], ["+598", "+598 (UY)"], ["+599", "+599 (AN)"], ["+670", "+670 (TL)"], ["+673", "+673 (BN)"], ["+674", "+674 (NR)"], ["+675", "+675 (PG)"], ["+676", "+676 (TO)"], ["+677", "+677 (SB)"], ["+678", "+678 (VU)"], ["+679", "+679 (FJ)"], ["+680", "+680 (PW)"], ["+681", "+681 (WF)"], ["+682", "+682 (CK)"], ["+683", "+683 (NU)"], ["+685", "+685 (WS)"], ["+686", "+686 (KI)"], ["+687", "+687 (NC)"], ["+688", "+688 (TV)"], ["+689", "+689 (PF)"], ["+690", "+690 (TK)"], ["+691", "+691 (FM)"], ["+692", "+692 (MH)"], ["+850", "+850 (KP)"], ["+852", "+852 (HK)"], ["+853", "+853 (MO)"], ["+855", "+855 (KH)"], ["+856", "+856 (LA)"], ["+880", "+880 (BD)"], ["+886", "+886 (TW)"], ["+960", "+960 (MV)"], ["+961", "+961 (LB)"], ["+962", "+962 (JO)"], ["+963", "+963 (SY)"], ["+964", "+964 (IQ)"], ["+965", "+965 (KW)"], ["+966", "+966 (SA)"], ["+967", "+967 (YE)"], ["+968", "+968 (OM)"], ["+970", "+970 (PS)"], ["+971", "+971 (AE)"], ["+972", "+972 (IL)"], ["+973", "+973 (BH)"], ["+974", "+974 (QA)"], ["+975", "+975 (BT)"], ["+976", "+976 (MN)"], ["+977", "+977 (NP)"], ["+992", "+992 (TJ)"], ["+993", "+993 (TM)"], ["+994", "+994 (AZ)"], ["+995", "+995 (GE)"], ["+996", "+996 (KY)"]]
    options.each { |option| option.reverse! }
    options
  end

  def profit_in_string(profit, include_unit = false)
    if profit.zero?
      # Profit is 'Void' with some the handicap bets
      return 0
    else
      sign = '+' if  profit > 0
      "#{sign}#{profit} #{I18n.t('tipster.units') if include_unit}"
    end
  end

  def hit_rate_in_string(hit_rate)
    "#{hit_rate}%"
  end

  def yield_in_string(_yield)
    "#{_yield}%"
  end

  def profitable_months_in_string(number_profitable_months, total_months)
    "#{number_profitable_months}/#{total_months}"
  end

  def class_for_tip_status(status)
    case status
      when Tip::STATUS_PENDING
        'text-warning'
      when Tip::STATUS_REJECTED
        'text-muted'
      when Tip::STATUS_PUBLISHED
        'text-info'
      when Tip::STATUS_FINISHED
        'text-success'
      else
        ''
    end
  end

end
