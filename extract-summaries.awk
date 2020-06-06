#!/usr/bin/awk -f

BEGIN {
  FS=":";

  in_todo = 0;
  in_summary = 0;
  summary = "";
  sortorder = -1;
}

function sanitize_summary_content(content) {
  gsub(/[\r\n]/, "", content);
  gsub(/\\,/, ",", content);
  gsub(/\\;/, ";", content);
  return content;
}

/^ / {
  if (in_summary) {
    content = substr($0, 2); # remove leading space
    content = sanitize_summary_content(content);
    summary = summary content;
  }
  # else it is probably a multiline X-FRUUX-URL
}

/^[^ ]/ {
  if (in_summary) {
    in_summary = 0;
  }
}

/^BEGIN:VTODO/ {
  in_todo = 1;
}

/^SUMMARY:/ {
  if(!in_todo) { exit 1; }

  in_summary = 1;
  sub(/^SUMMARY:/, ""); # we don't rely on FS here because that messes with colons in summary content
  summary = sanitize_summary_content($0);
}

/^X-APPLE-SORT-ORDER:/ {
  if (!in_todo) { exit 3; }

  sortorder = $2;
}

/^END:VTODO/ {
  print sortorder+0, summary # FIXME: why is +0 necessary?
  in_todo = 0;
  in_summary = 0;
  summary = "";
  sortorder = -1;
}
