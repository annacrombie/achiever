# frozen_string_literal: true

# Tasks for preparing badges for use in the app
#
# requirements:
#
# aws-cli/1.16.121
# ImageMagick 7.0.8-27
# node:
#   gmsmith 0.6.4
#   spritesmith-cli

# Temporary working directory
TMPDIR   = '/tmp/achiever-badges'
# Directory to store minified images
MINDIR   = File.join(TMPDIR, 'minified')
# Filename of generated spritesheet
TMPSHEET = File.join(TMPDIR, 'badges.png')
# Filename of temporary css
TMPCSS = File.join(TMPDIR, 'badges.css')

namespace :achiever do
  namespace :badges do
    desc 'Minify badges'
    task :minify do
      badge_dir = Rails.root.join(Achiever.icon_cfg[:source]).to_s
      width     = Achiever.icon_cfg[:output][:width].to_s

      if !File.exist?(TMPDIR) || !File.exist?(MINDIR) ||
         File.mtime(badge_dir) > File.mtime(MINDIR)
        sh 'mkdir', '-p', TMPDIR
        sh 'mkdir', '-p', MINDIR

        sh(
          'mogrify',
          '-path', MINDIR,
          '-filter', 'Triangle',
          '-define', 'filter:support=2',
          '-thumbnail', width,
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
          *Dir.glob("#{badge_dir}/**/*.png")
        )
      end
    end

    desc 'Spritify badges'
    task spritify: :minify do
      key = Achiever.icon_cfg[:output][:image]
      badge_out = Rails.root.join(Achiever.icon_cfg[:output][:dir], key).to_s
      css_out = Rails.root.join(Achiever.icon_cfg[:output][:css]).to_s

      image_source =
        if Achiever.use_aws_in_production?
          bucket = Achiever.icon_cfg[:output][:aws_bucket]
          raise(
            ArgumentError,
            'please set the Achiever.icon_cfg[:output][:aws_bucket] setting'
          ) unless bucket.is_a?(String)

          "<%= Rails.env == 'development' ? asset_path('#{key}') : 'http://s3.amazonaws.com/#{bucket}/#{key}' %>"
        else
          "<%= asset_path('#{key}') %>"
        end

      if !File.exist?(badge_out) || !File.exist?(css_out) ||
         File.mtime(MINDIR) > File.mtime(badge_out) ||
         File.mtime(MINDIR) > File.mtime(css_out)

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
          image_source
        ).yield_self { |css| File.write(TMPCSS, css) }

        sh 'cp', TMPSHEET, badge_out
        sh 'cp', TMPCSS, css_out
      end
    end

    desc 'Upload badges to aws'
    task upload: %i[environment spritify] do
      key = Achiever.icon_cfg[:output][:image]
      bucket = Achiever.icon_cfg[:output][:aws_bucket]
      raise(
        ArgumentError,
        'please set the Achiever.icon_cfg[:output][:aws_bucket] setting'
      ) unless bucket.is_a?(String)

      sh(
        'aws', 's3',
        'cp', TMPSHEET, "s3://#{bucket}/#{key}"
      )

      sh(
        'aws', 's3api', 'put-object-acl',
        '--bucket', bucket,
        '--key', key,
        '--acl', 'public-read'
      )
    end

    desc 'Minify badges, export sprite sheet'
    task prepare: :spritify
  end
end
