//
//  Copyright (C) 2011-2012 Robert Dyer, Rico Tzschichholz
//
//  This file is part of Plank.
//
//  Plank is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Plank is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Plank
{
	/**
	 * A themed renderer for windows.
	 */
	public abstract class Theme : Preferences
	{
		public const string DEFAULT_NAME = "Default";
		public const string GTK_THEME_NAME = "Gtk+";
		
		public static Gtk.StyleContext create_style_context (GLib.Type widget_type, Gtk.StyleContext? parent_style,
			Gtk.CssProvider provider, string? object_name, string first_class, ...)
		{
			Gtk.WidgetPath path;

			var style = new Gtk.StyleContext ();
			style.set_parent (parent_style);

			if (parent_style != null)
				path = parent_style.get_path ().copy ();
			else
				path = new Gtk.WidgetPath ();

			path.append_type (widget_type);

			if (object_name != null)
				PlankCompat.gtk_widget_path_iter_set_object_name (path, -1, object_name);

			path.iter_add_class (-1, first_class);
			var name_list = va_list ();
			for (unowned string? name = name_list.arg<unowned string> (); name != null; name = name_list.arg<unowned string> ())
				path.iter_add_class (-1, name);

			style.set_path (path);
			style.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS);

			return style;
		}
		
		[Description(nick = "top-roundness", blurb = "The roundness of the top corners.")]
		public int TopRoundness { get; set; }
		
		[Description(nick = "bottom-roundness", blurb = "The roundness of the bottom corners.")]
		public int BottomRoundness { get; set; }
		
		[Description(nick = "line-width", blurb = "The thickness (in pixels) of lines drawn.")]
		public int LineWidth { get; set; }
		
		[Description(nick = "outer-stroke-color", blurb = "The color (RGBA) of the outer stroke.")]
		public Color OuterStrokeColor { get; set; }
		
		[Description(nick = "fill-start-color", blurb = "The starting color (RGBA) of the fill gradient.")]
		public Color FillStartColor { get; set; }
		
		[Description(nick = "fill-end-color", blurb = "The ending color (RGBA) of the fill gradient.")]
		public Color FillEndColor { get; set; }
		
		[Description(nick = "inner-stroke-color", blurb = "The color (RGBA) of the inner stroke.")]
		public Color InnerStrokeColor { get; set; }

		[Description(nick = "glass-highlight-color", blurb = "Optional translucent highlight drawn over the upper part of the dock background.")]
		public Color GlassHighlightColor { get; set; }

		[Description(nick = "accent-line-color", blurb = "Optional accent line drawn near the open edge of the dock background.")]
		public Color AccentLineColor { get; set; }

		[Description(nick = "glow-stroke-color", blurb = "Optional outer glow around the dock background.")]
		public Color GlowStrokeColor { get; set; }

		[Description(nick = "scanline-color", blurb = "Optional scanline overlay color for futuristic glass themes.")]
		public Color ScanlineColor { get; set; }

		[Description(nick = "scanline-size", blurb = "Height of each scanline in pixels. Set to 0 to disable scanlines.")]
		public int ScanlineSize { get; set; }

		[Description(nick = "scanline-spacing", blurb = "Distance between scanlines in pixels.")]
		public int ScanlineSpacing { get; set; }

		[Description(nick = "glow-strength", blurb = "Opacity multiplier for the optional dock outer glow, from 0 to 1.")]
		public double GlowStrength { get; set; }

		[Description(nick = "background-pulse-enabled", blurb = "Whether the dock background draws an animated holographic sweep.")]
		public bool BackgroundPulseEnabled { get; set; }

		[Description(nick = "background-pulse-color", blurb = "Color of the animated background sweep.")]
		public Color BackgroundPulseColor { get; set; }

		[Description(nick = "background-pulse-time", blurb = "Time in milliseconds for one full background sweep.")]
		public int BackgroundPulseTime { get; set; }

		[Description(nick = "background-pulse-strength", blurb = "Opacity multiplier for the animated background sweep, from 0 to 1.")]
		public double BackgroundPulseStrength { get; set; }

		[Description(nick = "grid-overlay-color", blurb = "Optional circuit-grid overlay color for futuristic themes.")]
		public Color GridOverlayColor { get; set; }

		[Description(nick = "grid-overlay-size", blurb = "Circuit-grid line width in pixels. Set to 0 to disable.")]
		public int GridOverlaySize { get; set; }

		[Description(nick = "grid-overlay-spacing", blurb = "Circuit-grid spacing in pixels.")]
		public int GridOverlaySpacing { get; set; }

		[Description(nick = "corner-accent-color", blurb = "Optional angular corner accent color.")]
		public Color CornerAccentColor { get; set; }

		[Description(nick = "corner-accent-size", blurb = "Length of each angular corner accent in pixels. Set to 0 to disable.")]
		public int CornerAccentSize { get; set; }
		
		File? theme_folder;
		Gtk.StyleContext style_context;
		
		protected Theme ()
		{
			theme_folder = get_theme_folder (DEFAULT_NAME);
		}
		
		protected Theme.with_name (string name)
		{
			theme_folder = get_theme_folder (name);
		}
		
		construct
		{
			unowned Gtk.Settings gtk_settings = Gtk.Settings.get_default ();
			
			var theme_name = gtk_settings.gtk_theme_name;
			update_style_context (theme_name);
			
			gtk_settings.notify["gtk-theme-name"].connect (gtk_theme_name_changed);
		}
		
		void update_style_context (string? theme_name)
		{
			Gtk.CssProvider provider;
			if (theme_name != null)
				provider = Gtk.CssProvider.get_named (theme_name, null);
			else
				provider = new Gtk.CssProvider();
			
			style_context = Theme.create_style_context (typeof (Gtk.IconView), null, provider,
				"iconview", Gtk.STYLE_CLASS_VIEW);
			
			style_context.set_state (Gtk.StateFlags.FOCUSED | Gtk.StateFlags.SELECTED);
		}
		
		void gtk_theme_name_changed (Object o, ParamSpec p)
		{
			var theme_name = ((Gtk.Settings) o).gtk_theme_name;
			update_style_context (theme_name);
			
			notify (new ParamSpecBoolean ("theme-changed", "theme-changed", "theme-changed", true, ParamFlags.READABLE));
		}
		
		public unowned Gtk.StyleContext get_style_context ()
		{
			return style_context;
		}
		
		/**
		 * {@inheritDoc}
		 */
		protected override void reset_properties ()
		{
			TopRoundness    = 6;
			BottomRoundness = 6;
			
			LineWidth = 1;
			
			OuterStrokeColor = { 0.1647, 0.1647, 0.1647, 1.0 };
			FillStartColor   = { 0.1647, 0.1647, 0.1647, 1.0 };
			FillEndColor     = { 0.3176, 0.3176, 0.3176, 1.0 };
			InnerStrokeColor = { 1.0, 1.0, 1.0, 1.0 };
			GlassHighlightColor = { 1.0, 1.0, 1.0, 0.0 };
			AccentLineColor = { 1.0, 1.0, 1.0, 0.0 };
			GlowStrokeColor = { 1.0, 1.0, 1.0, 0.0 };
			ScanlineColor = { 1.0, 1.0, 1.0, 0.0 };
			ScanlineSize = 0;
			ScanlineSpacing = 8;
			GlowStrength = 0.0;
			BackgroundPulseEnabled = false;
			BackgroundPulseColor = { 1.0, 1.0, 1.0, 0.0 };
			BackgroundPulseTime = 3000;
			BackgroundPulseStrength = 0.0;
			GridOverlayColor = { 1.0, 1.0, 1.0, 0.0 };
			GridOverlaySize = 0;
			GridOverlaySpacing = 18;
			CornerAccentColor = { 1.0, 1.0, 1.0, 0.0 };
			CornerAccentSize = 0;
		}
		
		/**
		 * Loads a theme for the renderer to use.
		 *
		 * @param type the type of theme to load
		 */
		public void load (string type)
		{
			// if there is no folder available, fallback to the internal defaults
			if (theme_folder == null) {
				reset_properties ();
				return;
			}
			
			init_from_file (theme_folder.get_child ("%s.theme".printf (type)));
		}
		
		/**
		 * Returns the top offset.
		 *
		 * @return the top offset
		 */
		public int get_top_offset ()
		{
			return 2 * LineWidth;
		}
		
		/**
		 * Returns the bottom offset.
		 *
		 * @return the bottom offset
		 */
		public int get_bottom_offset ()
		{
			return BottomRoundness > 0 ? 2 * LineWidth : 0;
		}
		
		/**
		 * Draws a background onto the surface.
		 *
		 * @param surface the surface to draw on
		 */
		public void draw_background (Surface surface)
		{
			unowned Cairo.Context cr = surface.Context;
			Cairo.Pattern gradient;
			var width = surface.Width;
			var height = surface.Height;
			var bottom_offset = BottomRoundness > 0 ? LineWidth : -LineWidth;
			var rect_x = LineWidth / 2.0;
			var rect_y = LineWidth / 2.0;
			var rect_width = width - LineWidth;
			var rect_height = height - LineWidth / 2.0 - bottom_offset / 2.0;
			
			cr.save ();

			if (GlowStrength > 0.0 && GlowStrokeColor.alpha > 0.0 && LineWidth > 0) {
				for (var i = 3; i >= 1; i--) {
					cr.set_line_width (LineWidth + i * 2.0);
					cr.set_source_rgba (GlowStrokeColor.red, GlowStrokeColor.green, GlowStrokeColor.blue,
						GlowStrokeColor.alpha * GlowStrength * (0.12 * i));
					draw_rounded_rect (cr, rect_x, rect_y, rect_width, rect_height,
						TopRoundness + i, BottomRoundness + i, LineWidth + i * 2.0);
					cr.stroke ();
				}
			}
			
			gradient = new Cairo.Pattern.linear (0, 0, 0, height);
			gradient.add_color_stop_rgba (0, FillStartColor.red, FillStartColor.green, FillStartColor.blue, FillStartColor.alpha);
			gradient.add_color_stop_rgba (1, FillEndColor.red, FillEndColor.green, FillEndColor.blue, FillEndColor.alpha);
			
			cr.set_source (gradient);
			draw_rounded_rect (cr, rect_x, rect_y, rect_width, rect_height,
				TopRoundness, BottomRoundness, LineWidth);
			cr.fill ();

			cr.save ();
			draw_rounded_rect (cr, rect_x, rect_y, rect_width, rect_height,
				TopRoundness, BottomRoundness, LineWidth);
			cr.clip ();

			if (GlassHighlightColor.alpha > 0.0) {
				var highlight_height = double.max (1.0, height * 0.55);
				gradient = new Cairo.Pattern.linear (0, 0, 0, highlight_height);
				gradient.add_color_stop_rgba (0.0, GlassHighlightColor.red, GlassHighlightColor.green, GlassHighlightColor.blue,
					GlassHighlightColor.alpha);
				gradient.add_color_stop_rgba (0.45, GlassHighlightColor.red, GlassHighlightColor.green, GlassHighlightColor.blue,
					GlassHighlightColor.alpha * 0.32);
				gradient.add_color_stop_rgba (1.0, GlassHighlightColor.red, GlassHighlightColor.green, GlassHighlightColor.blue, 0.0);
				cr.rectangle (0, 0, width, highlight_height);
				cr.set_source (gradient);
				cr.fill ();
			}

			if (ScanlineSize > 0 && ScanlineSpacing > 0 && ScanlineColor.alpha > 0.0) {
				cr.set_source_rgba (ScanlineColor.red, ScanlineColor.green, ScanlineColor.blue, ScanlineColor.alpha);
				for (var y = LineWidth; y < height; y += ScanlineSpacing) {
					cr.rectangle (LineWidth, y, double.max (0.0, width - 2.0 * LineWidth), ScanlineSize);
					cr.fill ();
				}
			}

			if (GridOverlaySize > 0 && GridOverlaySpacing > 0 && GridOverlayColor.alpha > 0.0) {
				cr.save ();
				cr.set_line_width (GridOverlaySize);
				cr.set_source_rgba (GridOverlayColor.red, GridOverlayColor.green, GridOverlayColor.blue, GridOverlayColor.alpha);
				for (var gx = LineWidth + GridOverlaySpacing; gx < width - LineWidth; gx += GridOverlaySpacing) {
					cr.move_to (gx, LineWidth);
					cr.line_to (gx, height - LineWidth);
				}
				for (var gy = LineWidth + GridOverlaySpacing; gy < height - LineWidth; gy += GridOverlaySpacing) {
					cr.move_to (LineWidth, gy);
					cr.line_to (width - LineWidth, gy);
				}
				cr.stroke ();
				cr.restore ();
			}

			if (CornerAccentSize > 0 && CornerAccentColor.alpha > 0.0) {
				var accent = double.min (CornerAccentSize, double.min (width, height) / 3.0);
				var inset = LineWidth + 2.0;
				cr.save ();
				cr.set_line_width (double.max (1.0, LineWidth));
				cr.set_source_rgba (CornerAccentColor.red, CornerAccentColor.green, CornerAccentColor.blue, CornerAccentColor.alpha);
				cr.move_to (inset, inset + accent); cr.line_to (inset, inset); cr.line_to (inset + accent, inset);
				cr.move_to (width - inset - accent, inset); cr.line_to (width - inset, inset); cr.line_to (width - inset, inset + accent);
				cr.move_to (inset, height - inset - accent); cr.line_to (inset, height - inset); cr.line_to (inset + accent, height - inset);
				cr.move_to (width - inset - accent, height - inset); cr.line_to (width - inset, height - inset); cr.line_to (width - inset, height - inset - accent);
				cr.stroke ();
				cr.restore ();
			}

			if (AccentLineColor.alpha > 0.0) {
				var line_width = double.max (1.0, LineWidth);
				var y = double.max (line_width, height - bottom_offset - 1.5 * line_width);
				gradient = new Cairo.Pattern.linear (LineWidth, y, width - LineWidth, y);
				gradient.add_color_stop_rgba (0.0, AccentLineColor.red, AccentLineColor.green, AccentLineColor.blue, 0.0);
				gradient.add_color_stop_rgba (0.50, AccentLineColor.red, AccentLineColor.green, AccentLineColor.blue, AccentLineColor.alpha);
				gradient.add_color_stop_rgba (1.0, AccentLineColor.red, AccentLineColor.green, AccentLineColor.blue, 0.0);
				cr.set_source (gradient);
				cr.set_line_width (line_width);
				cr.move_to (LineWidth + TopRoundness, y);
				cr.line_to (width - LineWidth - TopRoundness, y);
				cr.stroke ();
			}

			cr.restore ();
			
			cr.set_source_rgba (OuterStrokeColor.red, OuterStrokeColor.green, OuterStrokeColor.blue, OuterStrokeColor.alpha);
			cr.set_line_width (LineWidth);
			draw_rounded_rect (cr, rect_x, rect_y, rect_width, rect_height,
				TopRoundness, BottomRoundness, LineWidth);
			cr.stroke ();
			
			gradient = new Cairo.Pattern.linear (0, 2 * LineWidth, 0, height - 2 * LineWidth - bottom_offset);
			gradient.add_color_stop_rgba (0, InnerStrokeColor.red, InnerStrokeColor.green, InnerStrokeColor.blue, 0.5 * InnerStrokeColor.alpha);
			gradient.add_color_stop_rgba ((TopRoundness > 0 ? TopRoundness : LineWidth) / (double) height, InnerStrokeColor.red, InnerStrokeColor.green, InnerStrokeColor.blue, 0.12 * InnerStrokeColor.alpha);
			gradient.add_color_stop_rgba (1 - (BottomRoundness > 0 ? BottomRoundness : LineWidth) / (double) height, InnerStrokeColor.red, InnerStrokeColor.green, InnerStrokeColor.blue, 0.08 * InnerStrokeColor.alpha);
			gradient.add_color_stop_rgba (1, InnerStrokeColor.red, InnerStrokeColor.green, InnerStrokeColor.blue, 0.19 * InnerStrokeColor.alpha);
			
			cr.set_source (gradient);
			draw_inner_rect (cr, width, height);
			cr.stroke ();
			
			cr.restore ();
		}
		
		/**
		 * Draws an animated holographic sweep over an already rendered background.
		 */
		public void draw_background_pulse (Cairo.Context cr, double x, double y, int width, int height, double phase)
		{
			if (!BackgroundPulseEnabled || BackgroundPulseColor.alpha <= 0.0 || BackgroundPulseStrength <= 0.0 || width <= 0 || height <= 0)
				return;

			phase = phase.clamp (0.0, 1.0);
			var bottom_offset = BottomRoundness > 0 ? LineWidth : -LineWidth;
			var rect_x = x + LineWidth / 2.0;
			var rect_y = y + LineWidth / 2.0;
			var rect_width = width - LineWidth;
			var rect_height = height - LineWidth / 2.0 - bottom_offset / 2.0;
			var sweep_center = x - width * 0.40 + phase * width * 1.80;
			var sweep_width = double.max (12.0, width * 0.42);

			var gradient = new Cairo.Pattern.linear (sweep_center - sweep_width, y, sweep_center + sweep_width, y);
			gradient.add_color_stop_rgba (0.00, BackgroundPulseColor.red, BackgroundPulseColor.green, BackgroundPulseColor.blue, 0.0);
			gradient.add_color_stop_rgba (0.46, BackgroundPulseColor.red, BackgroundPulseColor.green, BackgroundPulseColor.blue, 0.0);
			gradient.add_color_stop_rgba (0.50, BackgroundPulseColor.red, BackgroundPulseColor.green, BackgroundPulseColor.blue, BackgroundPulseColor.alpha * BackgroundPulseStrength);
			gradient.add_color_stop_rgba (0.54, BackgroundPulseColor.red, BackgroundPulseColor.green, BackgroundPulseColor.blue, BackgroundPulseColor.alpha * BackgroundPulseStrength * 0.34);
			gradient.add_color_stop_rgba (1.00, BackgroundPulseColor.red, BackgroundPulseColor.green, BackgroundPulseColor.blue, 0.0);

			cr.save ();
			draw_rounded_rect (cr, rect_x, rect_y, rect_width, rect_height, TopRoundness, BottomRoundness, LineWidth);
			cr.clip ();
			cr.rectangle (x, y, width, height);
			cr.set_source (gradient);
			cr.fill ();
			cr.restore ();
		}

		/**
		 * Similar to draw_rounded_rect, but moves in to avoid a containing rounded rect's lines.
		 *
		 * @param cr the context to draw with
		 * @param width the width of the rect
		 * @param height the height of the rect
		 */
		protected void draw_inner_rect (Cairo.Context cr, int width, int height)
		{
			var bottom_offset = BottomRoundness > 0 ? LineWidth : -LineWidth;
			
			draw_rounded_rect (cr,
				3 * LineWidth / 2.0,
				3 * LineWidth / 2.0,
				width - 3 * LineWidth,
				height - 3 * LineWidth / 2.0 - 3 * bottom_offset / 2.0,
				TopRoundness - LineWidth,
				BottomRoundness - LineWidth,
				LineWidth);
		}
		
		/**
		 * Draws a rounded rectangle.  If compositing is disabled, just draws a normal rectangle.
		 *
		 * @param cr the context to draw with
		 * @param x the x location of the rect
		 * @param y the y location of the rect
		 * @param width the width of the rect
		 * @param height the height of the rect
		 * @param top_radius the roundedness of the top edge
		 * @param bottom_radius the roundedness of the bottom edge
		 * @param line_width the line-width of the rect
		 */
		public static void draw_rounded_rect (Cairo.Context cr, double x, double y, double width, double height, double top_radius = 6.0, double bottom_radius = 6.0, double line_width = 1.0)
		{
			var min_size  = double.min (width, height);
			
			top_radius = top_radius.clamp (0.0, min_size);
			bottom_radius = bottom_radius.clamp (0.0, min_size - top_radius);
			
			if (!Gdk.Screen.get_default ().is_composited ())
				top_radius = bottom_radius = 0.0;
			
			// if the top isnt round, we have to adjust the starting point a bit
			if (top_radius == 0.0)
				cr.move_to (x - line_width / 2.0, y);
			else
				cr.move_to (x + top_radius, y);
			
			cr.arc (x + width - top_radius,    y + top_radius,             top_radius,    -Math.PI_2, 0);
			cr.arc (x + width - bottom_radius, y + height - bottom_radius, bottom_radius, 0,           Math.PI_2);
			cr.arc (x + bottom_radius,         y + height - bottom_radius, bottom_radius, Math.PI_2,   Math.PI);
			cr.arc (x + top_radius,            y + top_radius,             top_radius,    Math.PI,     -Math.PI_2);
			cr.close_path ();
		}
		
		/**
		 * Draws a rounded horizontal line.
		 *
		 * @param cr the context to draw with
		 * @param x the x location of the line
		 * @param y the y location of the line
		 * @param width the width of the line
		 * @param height the height of the line
		 * @param is_round_left weather the left is round or not
		 * @param is_round_right weather the right is round or not
		 * @param stroke filling style of the outline
		 * @param fill filling style of the inner area
		 */
		public static void draw_rounded_line (Cairo.Context cr, double x, double y, double width, double height, bool is_round_left, bool is_round_right, Cairo.Pattern? stroke = null, Cairo.Pattern? fill = null)
		{
			if (height > width) {
				y += Math.floor ((height - width) / 2.0);
				height = width;
			}
			
			height = 2.0 * Math.floor (height / 2.0);
			
			var left_radius = is_round_left ? height / 2.0 : 0.0;
			var right_radius = is_round_right ? height / 2.0 : 0.0;
			
			cr.move_to (x + width - right_radius, y);
			cr.line_to (x + left_radius, y);
			if (is_round_left)
				cr.arc_negative (x + left_radius, y + left_radius, left_radius, -Math.PI_2, Math.PI_2);
			else
				cr.line_to (x, y + height);
			cr.line_to (x + width - right_radius, y + height);
			if (is_round_right)
				cr.arc_negative (x + width - right_radius, y + right_radius, right_radius, Math.PI_2, -Math.PI_2);
			else
				cr.line_to (x + width, y);
			cr.close_path ();
			
			if (fill != null) {
				cr.set_source (fill);
				cr.fill_preserve ();
			}
			if (stroke != null)
				cr.set_source (stroke);
			cr.stroke ();
		}
		
		/**
		 * {@inheritDoc}
		 */
		protected override void verify (string prop)
		{
			base.verify (prop);
			
			switch (prop) {
			case "TopRoundness":
				if (TopRoundness < 0)
					TopRoundness = 0;
				break;
			
			case "BottomRoundness":
				if (BottomRoundness < 0)
					BottomRoundness = 0;
				break;
			
			case "LineWidth":
				if (LineWidth < 0)
					LineWidth = 0;
				break;
			
			case "OuterStrokeColor":
				break;
			
			case "FillStartColor":
				break;
			
			case "FillEndColor":
				break;
			
			case "InnerStrokeColor":
				break;

			case "GlassHighlightColor":
			case "AccentLineColor":
			case "GlowStrokeColor":
			case "ScanlineColor":
			case "BackgroundPulseColor":
			case "GridOverlayColor":
			case "CornerAccentColor":
			case "BackgroundPulseEnabled":
				break;

			case "ScanlineSize":
				if (ScanlineSize < 0)
					ScanlineSize = 0;
				break;

			case "ScanlineSpacing":
				if (ScanlineSpacing < 1)
					ScanlineSpacing = 1;
				break;

			case "GlowStrength":
				if (GlowStrength < 0.0)
					GlowStrength = 0.0;
				else if (GlowStrength > 1.0)
					GlowStrength = 1.0;
				break;

			case "BackgroundPulseTime":
				if (BackgroundPulseTime < 0)
					BackgroundPulseTime = 0;
				break;

			case "BackgroundPulseStrength":
				if (BackgroundPulseStrength < 0.0)
					BackgroundPulseStrength = 0.0;
				else if (BackgroundPulseStrength > 1.0)
					BackgroundPulseStrength = 1.0;
				break;

			case "GridOverlaySize":
				if (GridOverlaySize < 0)
					GridOverlaySize = 0;
				break;

			case "GridOverlaySpacing":
				if (GridOverlaySpacing < 1)
					GridOverlaySpacing = 1;
				break;

			case "CornerAccentSize":
				if (CornerAccentSize < 0)
					CornerAccentSize = 0;
				break;
			}
		}
		
		/**
		 * Get a sorted array of all available theme-names
		 *
		 * @return array containing all available theme-names
		 */
		public static string[] get_theme_list ()
		{
			var list = new Gee.HashSet<string> ();
			
			list.add (DEFAULT_NAME);
			list.add (GTK_THEME_NAME);
			
			// Look in user's themes-folder
			try {
				var enumerator = Paths.AppThemeFolder.enumerate_children (FileAttribute.STANDARD_NAME + ","
					+ FileAttribute.STANDARD_TYPE + "," + FileAttribute.STANDARD_IS_HIDDEN,
					GLib.FileQueryInfoFlags.NONE);
				FileInfo info;
				while ((info = enumerator.next_file ()) != null) {
					if (info.get_is_hidden ()
						|| info.get_file_type () != GLib.FileType.DIRECTORY)
						continue;
					
					list.add (info.get_name ());
				}
			} catch {}
			
			// Look in system's themes-folder
			try {
				var enumerator = Paths.ThemeFolder.enumerate_children (FileAttribute.STANDARD_NAME + ","
					+ FileAttribute.STANDARD_TYPE + "," + FileAttribute.STANDARD_IS_HIDDEN,
					GLib.FileQueryInfoFlags.NONE);
				FileInfo info;
				while ((info = enumerator.next_file ()) != null) {
					if (info.get_is_hidden ()
						|| info.get_file_type () != GLib.FileType.DIRECTORY)
						continue;
					
					list.add (info.get_name ());
				}
			} catch {}
			
			var result = new Gee.ArrayList<string> ();
			result.add_all (list);
			result.sort ();
			
			return result.to_array ();
		}
		
		/**
		 * Try to get an already existing folder located in the
		 * themes folder while prefering the user's themes folder.
		 * If there is no folder found we fallback to the "Default" theme.
		 * If even that folder doesn't exist return NULL (and use built-in defaults)
		 *
		 * @param name the basename of the folder
		 * @return {@link GLib.File} the folder of the theme or NULL
		 */
		public static File? get_theme_folder (string name)
		{
			if (name == DEFAULT_NAME)
				return get_default_theme_folder ();
			
			if (name == GTK_THEME_NAME)
				return get_gtk_theme_folder ();
			
			File folder;
			
			// Look in user's themes-folder
			folder = Paths.AppThemeFolder.get_child (name);
			if (folder.query_exists ()
				&& folder.query_file_type (FileQueryInfoFlags.NONE, null) == FileType.DIRECTORY)
				return folder;
			
			// Look in system's themes-folder
			folder = Paths.ThemeFolder.get_child (name);
			if (folder.query_exists ()
				&& folder.query_file_type (FileQueryInfoFlags.NONE, null) == FileType.DIRECTORY)
				return folder;
			
			warning ("%s not found, falling back to %s.", name, DEFAULT_NAME);
			
			return get_default_theme_folder ();
		}
		
		static File? get_default_theme_folder ()
		{
			File folder;
			
			// "Default" folder located in system's themes-folder
			folder = Paths.ThemeFolder.get_child (DEFAULT_NAME);
			if (folder.query_exists ()
				&& folder.query_file_type (FileQueryInfoFlags.NONE, null) == FileType.DIRECTORY)
				return folder;
			
			warning ("%s is not a folder fallback to the built-in defaults!", folder.get_path ());
			
			return null;
		}
		
		static File? get_gtk_theme_folder ()
		{
			File folder;
			unowned string exec_name = Paths.AppName;
			var name = Gtk.Settings.get_default ().gtk_theme_name;
					
			// Look in user's xdg-themes-folder
			folder = Paths.DataHomeFolder.get_child ("themes/%s".printf (name));
			if (folder.query_exists ()) {
				folder = folder.get_child (exec_name);
				if (folder.query_exists ()
					&& folder.query_file_type (FileQueryInfoFlags.NONE, null) == FileType.DIRECTORY)
					return folder;
				
				warning ("Currently selected gtk+ theme '%s' does not provide a dock theme, fallback to the built-in defaults!", name);
				return null;
			}
			
			// Look in user's legacy xdg-themes-folder
			folder = Paths.HomeFolder.get_child (".themes/%s".printf (name));
			if (folder.query_exists ()) {
				folder = folder.get_child (exec_name);
				if (folder.query_exists ()
					&& folder.query_file_type (FileQueryInfoFlags.NONE, null) == FileType.DIRECTORY)
					return folder;
				
				warning ("Currently selected gtk+ theme '%s' does not provide a dock theme, fallback to the built-in defaults!", name);
				return null;
			}
			
			// Look in system's xdg-themes-folders
			foreach (var datafolder in Paths.DataDirFolders) {
				folder = datafolder.get_child ("themes/%s/%s".printf (name, exec_name));
				if (folder.query_exists ()
					&& folder.query_file_type (FileQueryInfoFlags.NONE, null) == FileType.DIRECTORY)
					return folder;
			}
			
			warning ("Currently selected gtk+ theme '%s' does not provide a dock theme, fallback to the built-in defaults!", name);
			return null;
		}
	}
}
