import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Hacked By ./SaklarRusak",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body style={{ margin: 0, padding: 0, background: "black" }}>
        <div style={{ width: "100vw", height: "100vh" }}>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="100%"
            height="100%"
            viewBox="0 0 800 400"
            preserveAspectRatio="xMidYMid meet"
          >
            <style>{`
              .bg {
                fill: black;
              }
              .main {
                font-family: monospace;
                font-size: 48px;
                fill: #00ff00;
                text-anchor: middle;
              }
              .sub {
                font-family: monospace;
                font-size: 18px;
                fill: #00cc00;
                text-anchor: middle;
              }
              .subb {
                font-family: monospace;
                font-size: 18px;
                fill: #ff0000;
                text-anchor: middle;
              }
            `}</style>

            {/* background */}
            <rect x="0" y="0" width="200%" height="200%" className="bg" />

            {/* main text */}
            <text x="400" y="190" className="main">
              hacked by ./SaklarRusak
            </text>

            <text x="400" y="230" className="sub">
              tsecnetwork.my.id : k4puyu4k - halisia - temo - cepu_sosial - wsl&apos;users
            </text>

            <text x="400" y="330" className="subb">
              #FuckYou_Mafia
            </text>

            <text x="400" y="360" className="subb">
              #havefun_just_filling_my_free_time_because_I&apos;m_incredibly_busy
            </text>
          </svg>
        </div>

        {children}

        <script
          dangerouslySetInnerHTML={{
            __html: `alert("hacked by ./saklarrusak");`,
          }}
        />
      </body>
    </html>
  );
}
