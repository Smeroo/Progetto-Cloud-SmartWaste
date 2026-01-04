import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Standalone output for Docker optimization
  // This creates a minimal production build with only necessary files
  output: 'standalone',
  
  // Security: Remove X-Powered-By header
  poweredByHeader: false,
  
  // Enable compression for better performance
  compress: true,
  
  // Optimize images
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
    ],
  },
  
  // Strict mode for better development practices
  reactStrictMode: true,
  
  // Disable X-Powered-By header for security
  headers: async () => {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ];
  },
};

export default nextConfig;
