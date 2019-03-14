# Tasks for preparing badges for use in the app
#
# requirements:
#
# aws-cli/1.16.121
# ImageMagick 7.0.8-27
# node:
#   gmsmith 0.6.4
#   spritesmith-cli

require 'optparse'

# The directory the source badges are
BADGE_DIR = Rails.root.join('badges').to_s
# Width of the output badges in pixels
WIDTH     = '70'

# Temporary working directory
TMPDIR   = '/tmp/achiever-badges'
# Directory to store minified images
MINDIR   = File.join(TMPDIR, 'minified')

# The bucket and key to upload the result to
BUCKET    = 'mythreatadvice-public-bucket'
KEY       = 'badgesprites.png'

# Filename of generated spritesheet
TMPSHEET = File.join(TMPDIR, KEY)
# Output filename for generated badge
BADGE_OUT = Rails.root.join("public/#{KEY}").to_s

# Filename of temporary css
TMPCSS = File.join(TMPDIR, 'badges.css')
# Output filename for generated css
CSS_OUT   = Rails.root.join('app/assets/stylesheets/badges.css.erb').to_s

namespace :achiever do
  namespace :badges do
    desc 'Minify badges'
    task :minify do
      if !File.exist?(TMPDIR) || !File.exist?(MINDIR) ||
          File.mtime(BADGE_DIR) > File.mtime(MINDIR)
        sh 'mkdir', '-p', TMPDIR
        sh 'mkdir', '-p', MINDIR

        sh(
          'mogrify',
          '-path', MINDIR,
          '-filter', 'Triangle',
          '-define', 'filter:support=2',
          '-thumbnail', WIDTH,
          '-unsharp', '0.25x0.25+8+0.065',
          '-dither', 'None',
          '-posterize', '136',
          '-quality', '82',
          '-define', 'jpeg:fancy-upsampling=off',
          '-define', 'png:compression-filter=5',
          '-define', 'png:compression-level=9',
          '-define', 'png:compression-strategy=1',
          '-define', 'png:exclude-chunk=all',
          '-interlace', 'none',
          '-colorspace', 'sRGB',
          '-strip',
          *Dir.glob("#{BADGE_DIR}/**/*.png")
        )
      end
    end

    desc 'Spritify badges'
    task spritify: :minify do
      if !File.exist?(BADGE_OUT) || !File.exist?(CSS_OUT) ||
          File.mtime(MINDIR) > File.mtime(BADGE_OUT) ||
          File.mtime(MINDIR) > File.mtime(CSS_OUT)

        ssjs = File.join(TMPDIR, 'spritesmith.js')
        File.open(ssjs, 'w') do |f|
          f.write <<~HEREDOC
          'use strict';

          var util = require('util');

          module.exports = {
            src: '#{MINDIR}/**/*.png',
            destImage: '#{TMPSHEET}',
            destCSS: '#{TMPCSS}',
            imgPath: "IMGPATH",
            padding: 2,
            algorithm: 'binary-tree',
            algorithmOpts: { sort: false },
            engine: 'gmsmith',
            cssOpts: {
              cssClass: function (item) {
                return util.format('.badge_icon .%s', item.name);
              }
            }
          }
          HEREDOC
        end

        sh('spritesmith', '--rc', ssjs)

        File.read(TMPCSS).gsub(
          /IMGPATH/,
          "<%= Rails.env == 'development' ? 'http://localhost:3000/#{KEY}' : 'http://s3.amazonaws.com/#{BUCKET}/#{KEY}' %>"
        ).yield_self { |css| File.write(TMPCSS, css) }

        sh "cp", TMPSHEET, BADGE_OUT
        sh "cp", TMPCSS, CSS_OUT
      end
    end

    desc "Upload badges to aws"
    task upload: %i[environment spritify] do
      sh(
        'aws', 's3',
        'cp', TMPSHEET, "s3://#{BUCKET}/#{KEY}"
      )

      sh(
         'aws', 's3api', 'put-object-acl',
         '--bucket', BUCKET,
         '--key', KEY,
         '--acl', 'public-read'
      )
    end

    desc 'Minify badges, export sprite sheet'
    task prepare: :spritify
  end
end
