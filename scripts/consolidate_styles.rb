#!/usr/bin/env ruby
#
# consolidate_styles.rb (Sass Version)
#
# This script finds all CSS from inline <style> tags within a Jekyll `_site`
# directory, consolidates them, optimizes/minifies them, and saves the result
# into a single, clean CSS file using the stable `sass` gem.
#
# --- Setup ---
#
# 1. Make sure you have bundler installed: `gem install bundler`
# 2. Place the `Gemfile` (provided separately) in your project's root directory.
# 3. Install the gems for this project: `bundle install` (run this once)
# 4. Run the script directly: `ruby scripts/consolidate_styles.rb`
#

# This line loads the gems listed in your Gemfile.
require 'bundler/setup'

require 'nokogiri'
require 'sass'
require 'fileutils'

# --- Configuration ---
SITE_DIR = '_site'
OUTPUT_DIR = 'dist'
FINAL_CSS_FILE = File.join(OUTPUT_DIR, 'inline-styles.css')

# --- Script Start ---
puts "▶️ Starting inline style consolidation with Ruby..."

# 1. Check if the source directory exists
unless Dir.exist?(SITE_DIR)
  puts "❌ Error: Source directory '#{SITE_DIR}' not found."
  puts "   Please run 'jekyll build' first."
  exit 1
end

# 2. Find all HTML files in the site directory
html_files = Dir.glob(File.join(SITE_DIR, '**', '*.html'))

if html_files.empty?
  puts "⚠️ No HTML files found in '#{SITE_DIR}'. Exiting."
  exit 0
end

# 3. Extract all inline CSS content
puts "🔎 Finding and extracting inline styles from #{html_files.count} HTML files..."
all_styles = []

html_files.each do |file_path|
  doc = Nokogiri::HTML(File.open(file_path))
  doc.css('style').each do |style_tag|
    all_styles << style_tag.content
  end
end

if all_styles.empty?
  puts "⚠️ No inline <style> tags found. Output file was not created."
  exit 0
end

# 4. Consolidate and clean the CSS with the Sass gem
puts "🚀 Consolidating and optimizing all styles with Sass..."
consolidated_css = all_styles.join("\n")

# Use the Sass::Engine to process the combined CSS string.
begin
  # The :scss syntax is used because we are feeding it plain CSS.
  # The :compressed style minifies the output.
  engine = Sass::Engine.new(consolidated_css, syntax: :scss, style: :compressed)
  clean_css = engine.render
rescue Sass::SyntaxError => e
  puts "❌ Sass compilation failed:"
  puts "   Line #{e.sass_line}: #{e.message}"
  exit 1
end


# 5. Save the final CSS file
FileUtils.mkdir_p(OUTPUT_DIR)
File.write(FINAL_CSS_FILE, clean_css)

# --- Finish ---
puts "✅ Success! Consolidated CSS saved to '#{FINAL_CSS_FILE}'."
puts "   Final file size: #{File.size(FINAL_CSS_FILE)} bytes."
puts "✨ Done."

