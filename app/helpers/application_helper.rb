module ApplicationHelper
  def mode_icon(mode)
    {
      "base"                    => "🃏",
      "spaced_list"             => "🔄",
      "spaced_global"           => "🌍",
      "base_written"            => "✏️",
      "spaced_list_written"     => "📝",
      "spaced_global_written"   => "🌐",
    }[mode.to_s] || "🎮"
  end

  def accuracy_color(pct)
    if pct >= 80 then "text-emerald-600 dark:text-emerald-400"
    elsif pct >= 60 then "text-yellow-600 dark:text-yellow-400"
    else "text-red-500 dark:text-red-400"
    end
  end

  def format_points(pts)
    pts.to_f.round(1).to_s
  end
end
