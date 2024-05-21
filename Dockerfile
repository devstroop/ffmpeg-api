#####################################################################
#
# A Docker image to convert audio and video for web using web API
#
#   with
#     - FFMPEG (built)
#     - NodeJS
#     - fluent-ffmpeg
#
#   For more on Fluent-FFMPEG, see 
#
#            https://github.com/fluent-ffmpeg/node-fluent-ffmpeg
#
# Original image and FFMPEG API by Paul Visco
# https://github.com/surebert/docker-ffmpeg-service
#
#####################################################################

# Stage 1: Build
FROM node:16-alpine as build

RUN apk add --no-cache git

# Install pkg globally
RUN npm install -g pkg

# Define cache path for pkg
ENV PKG_CACHE_PATH /usr/cache

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json for dependency installation
COPY ./src/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY ./src .

# Create a single binary file
RUN pkg --targets node16-alpine-x64 /usr/src/app

# Stage 2: Production
FROM jrottenberg/ffmpeg:4.2-alpine311

# Create a non-root user
RUN adduser --disabled-password --home /home/ffmpgapi ffmpgapi

# Set working directory
WORKDIR /home/ffmpgapi

# Copy files from build stage
COPY --from=build /usr/src/app/ffmpegapi .
COPY --from=build /usr/src/app/index.md .

# Set proper permissions
RUN chown ffmpgapi:ffmpgapi * && chmod 755 ffmpegapi

# Expose port 3000
EXPOSE 3000

# Change to non-root user
USER ffmpgapi

# Define entrypoint and default command
ENTRYPOINT []
CMD ["./ffmpegapi"]