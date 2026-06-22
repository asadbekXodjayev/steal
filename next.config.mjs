/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: "http",
        hostname: "34.170.155.242",
        port: "8090",
      },
      {
        protocol: "https",
        hostname: "raw.githubusercontent.com",
        pathname: "/hasaneyldrm/exercises-dataset/**",
      },
      {
        protocol: "https",
        hostname: "static.exercisedb.dev",
      },
      {
        protocol: "https",
        hostname: "**.vercel.app",
      },
      {
        protocol: "https",
        hostname: "images.unsplash.com",
      },
    ],
  },
  // Proxy /pb/* → PocketBase so the browser never makes cross-origin HTTP
  // requests. This solves mixed-content (HTTPS Vercel → HTTP PocketBase).
  async rewrites() {
    const dest = process.env.POCKETBASE_INTERNAL_URL || "http://34.170.155.242:8090";
    return [
      {
        source: "/pb/:path*",
        destination: `${dest}/:path*`,
      },
    ];
  },
};

export default nextConfig;
