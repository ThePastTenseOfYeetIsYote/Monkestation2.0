/atom/movable/screen/escape_menu/text
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	maptext_width = 100
	maptext_height = 8

	var/list/screen_directions = list("NORTH", "WEST")
	VAR_PRIVATE/datum/escape_menu/escape_menu
	VAR_PRIVATE/button_text
	VAR_PRIVATE/font_size

/atom/movable/screen/escape_menu/text/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	list/offset,
	font_size = 12,
)
	. = ..()
	src.escape_menu = escape_menu
	src.button_text = button_text
	src.font_size = font_size

	//this decides how far out you can 'click' on this, so it's important to keep it short.
	//yes even here, maptext can still embed links without using clickable subtype.
	src.maptext_width = max(round(length(button_text) * font_size * 0.75), font_size * 4)
	src.maptext_height = round(font_size * 1.4)

	update_text()
	screen_loc = "[screen_directions[1]]:[offset[1]],[screen_directions[2]]:[offset[2]]"

/atom/movable/screen/escape_menu/text/proc/update_text()
	SHOULD_CALL_PARENT(TRUE)
	maptext = MAPTEXT_PIXELLARI("<span style='font-size: [font_size]px; color: [text_color()]'>[button_text]</span>")

/atom/movable/screen/escape_menu/text/proc/text_color()
	return enabled() ? "white" : "gray"

/atom/movable/screen/escape_menu/text/proc/enabled()
	return TRUE

///Scrolls the text upwards (by lowering maptext_y), called by the UI.
/atom/movable/screen/escape_menu/text/proc/scroll_up()
	animate(src,
		maptext_y = (maptext_y - 120),
		time = (1 SECONDS),
		easing = CUBIC_EASING|EASE_OUT,
	)

///Scrolls the text downwards (by increasing maptext_y), called by the UI.
/atom/movable/screen/escape_menu/text/proc/scroll_down()
	animate(src,
		maptext_y = (maptext_y + 120),
		time = (1 SECONDS),
		easing = CUBIC_EASING|EASE_OUT,
	)

///Clickable text, gets underlined when hovered and has an on_click_callback.
/atom/movable/screen/escape_menu/text/clickable
	VAR_PRIVATE/datum/callback/on_click_callback
	VAR_PRIVATE/hovered = FALSE

/atom/movable/screen/escape_menu/text/clickable/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	list/offset,
	font_size = 24,
	on_click_callback,
)
	. = ..()
	src.on_click_callback = on_click_callback

/atom/movable/screen/escape_menu/text/clickable/Destroy()
	on_click_callback = null
	return ..()

/atom/movable/screen/escape_menu/text/clickable/update_text()
	. = ..()
	if (hovered)
		maptext = "<u>[maptext]</u>"

/atom/movable/screen/escape_menu/text/clickable/Click(location, control, params)
	if (!enabled())
		return
	on_click_callback.InvokeAsync(src)

/atom/movable/screen/escape_menu/text/clickable/MouseEntered(location, control, params)
	set_hovered(TRUE)

/atom/movable/screen/escape_menu/text/clickable/MouseExited(location, control, params)
	set_hovered(FALSE)

/// Sets the hovered state of the button, and updates the text
/atom/movable/screen/escape_menu/text/clickable/proc/set_hovered(hovered)
	if (src.hovered == hovered)
		return

	src.hovered = hovered
	update_text()

/atom/movable/screen/escape_menu/text/center
	screen_directions = list("NORTH", "CENTER")
