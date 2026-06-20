import { useState } from "react";
import {
  AreaChart, Area, BarChart, Bar, XAxis, YAxis, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, LineChart, Line
} from "recharts";

// ─── Types ────────────────────────────────────────────────────────────────────

type Screen = "dashboard" | "sessions" | "courts" | "reservations" | "tournaments" | "analytics" | "expenses" | "settings";

interface Session {
  id: number;
  date: string;
  court: string;
  opponent: string;
  score: string;
  result: "W" | "L" | "D";
  type: "Competitive" | "Casual" | "Practice";
  duration: string;
  notes: string;
}

interface Court {
  id: number;
  name: string;
  location: string;
  type: "Indoor" | "Outdoor";
  surface: string;
  timesPlayed: number;
  lastPlayed: string;
  favorite: boolean;
}

interface Reservation {
  id: number;
  court: string;
  date: string;
  startTime: string;
  endTime: string;
  status: "Upcoming" | "Completed" | "Cancelled";
  notes: string;
}

interface Expense {
  id: number;
  amount: number;
  category: "Court Fees" | "Tournament Fees" | "Equipment" | "Coaching" | "Miscellaneous";
  date: string;
  notes: string;
}

interface Tournament {
  id: number;
  name: string;
  date: string;
  type: "Single Elimination" | "Double Elimination" | "Round Robin";
  entryFee: number;
  location: string;
  participants: string[];
  status: "Upcoming" | "Active" | "Completed";
  result?: string;
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

const SESSIONS: Session[] = [
  { id: 1, date: "Jun 20, 2025", court: "Central Court", opponent: "Alex, Sam", score: "W 11-7, 11-9", result: "W", type: "Competitive", duration: "1h 45m", notes: "" },
  { id: 2, date: "Jun 18, 2025", court: "Riverside Courts", opponent: "Mike Ross", score: "L 15-11", result: "L", type: "Casual", duration: "1h 20m", notes: "Good rallies, need to work on serve" },
  { id: 3, date: "Jun 15, 2025", court: "Park Side Courts", opponent: "Jordan, Casey", score: "W 11-6, 11-8", result: "W", type: "Competitive", duration: "2h 05m", notes: "" },
  { id: 4, date: "Jun 12, 2025", court: "Central Court", opponent: "Solo Drill", score: "—", result: "D", type: "Practice", duration: "1h 00m", notes: "Worked on backhand dink" },
  { id: 5, date: "Jun 10, 2025", court: "Riverside Courts", opponent: "Sam, Taylor", score: "W 11-9, 8-11, 11-7", result: "W", type: "Competitive", duration: "2h 15m", notes: "" },
  { id: 6, date: "Jun 8, 2025", court: "Central Court", opponent: "Chris", score: "L 11-13", result: "L", type: "Casual", duration: "50m", notes: "" },
  { id: 7, date: "Jun 5, 2025", court: "Park Side Courts", opponent: "Alex", score: "W 11-5, 11-7", result: "W", type: "Competitive", duration: "1h 30m", notes: "" },
  { id: 8, date: "Jun 2, 2025", court: "Central Court", opponent: "Jordan", score: "W 11-8, 11-10", result: "W", type: "Casual", duration: "1h 10m", notes: "" },
];

const COURTS: Court[] = [
  { id: 1, name: "Central Court", location: "123 Main St", type: "Indoor", surface: "Pro Surface", timesPlayed: 24, lastPlayed: "Jun 20, 2025", favorite: true },
  { id: 2, name: "Riverside Courts", location: "450 River Rd", type: "Outdoor", surface: "Asphalt", timesPlayed: 12, lastPlayed: "Jun 18, 2025", favorite: false },
  { id: 3, name: "Park Side Courts", location: "City Park, Gate 3", type: "Outdoor", surface: "Concrete", timesPlayed: 8, lastPlayed: "Jun 15, 2025", favorite: false },
];

const RESERVATIONS: Reservation[] = [
  { id: 1, court: "Central Court", date: "Jun 21, 2025", startTime: "7:00 AM", endTime: "8:30 AM", status: "Upcoming", notes: "Morning doubles session" },
  { id: 2, court: "Riverside Courts", date: "Jun 24, 2025", startTime: "6:00 PM", endTime: "7:30 PM", status: "Upcoming", notes: "" },
  { id: 3, court: "Central Court", date: "Jun 18, 2025", startTime: "8:00 AM", endTime: "9:30 AM", status: "Completed", notes: "" },
  { id: 4, court: "Park Side Courts", date: "Jun 14, 2025", startTime: "10:00 AM", endTime: "11:00 AM", status: "Cancelled", notes: "Rain cancellation" },
];

const EXPENSES: Expense[] = [
  { id: 1, amount: 25, category: "Court Fees", date: "Jun 20, 2025", notes: "Central Court 1.5h" },
  { id: 2, amount: 50, category: "Tournament Fees", date: "Jun 15, 2025", notes: "Summer Smash entry" },
  { id: 3, amount: 18.40, category: "Court Fees", date: "Jun 12, 2025", notes: "Riverside open play" },
  { id: 4, amount: 89, category: "Equipment", date: "Jun 8, 2025", notes: "New paddle grip + balls" },
  { id: 5, amount: 35, category: "Court Fees", date: "Jun 5, 2025", notes: "Central Court 2h" },
  { id: 6, amount: 120, category: "Coaching", date: "Jun 1, 2025", notes: "Private lesson" },
];

const TOURNAMENTS: Tournament[] = [
  { id: 1, name: "Summer Smash 2025", date: "Jun 15-16, 2025", type: "Single Elimination", entryFee: 50, location: "Central Court Complex", participants: ["You", "Alex", "Sam", "Mike", "Jordan", "Casey", "Taylor", "Chris"], status: "Active", result: "QF" },
  { id: 2, name: "City Open Spring", date: "Apr 12, 2025", type: "Round Robin", entryFee: 35, location: "City Park Courts", participants: ["You", "Alex", "Sam", "Jordan", "Taylor"], status: "Completed", result: "2nd Place" },
  { id: 3, name: "Riverside Doubles Cup", date: "Jul 20, 2025", type: "Double Elimination", entryFee: 60, location: "Riverside Courts", participants: [], status: "Upcoming" },
];

// ─── Chart Data ───────────────────────────────────────────────────────────────

const hoursData = [
  { month: "Jan", hours: 8 }, { month: "Feb", hours: 10 }, { month: "Mar", hours: 14 },
  { month: "Apr", hours: 11 }, { month: "May", hours: 18.6 }, { month: "Jun", hours: 12.5 },
];

const spendingData = [
  { month: "Jan", amount: 85 }, { month: "Feb", amount: 110 }, { month: "Mar", amount: 95 },
  { month: "Apr", amount: 140 }, { month: "May", amount: 119 }, { month: "Jun", amount: 337.40 },
];

const freqData = [
  { day: "Mon", sessions: 2 }, { day: "Tue", sessions: 0 }, { day: "Wed", sessions: 3 },
  { day: "Thu", sessions: 1 }, { day: "Fri", sessions: 2 }, { day: "Sat", sessions: 4 }, { day: "Sun", sessions: 1 },
];

const courtUsageData = [
  { name: "Central Court", value: 55, color: "#a1d494" },
  { name: "Riverside", value: 27, color: "#3b6934" },
  { name: "Park Side", value: 18, color: "#42493e" },
];

const expenseCategoryData = [
  { name: "Court Fees", value: 78.40, color: "#a1d494" },
  { name: "Equipment", value: 89, color: "#3b6934" },
  { name: "Coaching", value: 120, color: "#c2c9bb" },
  { name: "Tournament", value: 50, color: "#FFB4AB" },
];

// ─── Shared Components ────────────────────────────────────────────────────────

function StatCard({ label, value, sub, subPositive }: { label: string; value: string; sub?: string; subPositive?: boolean }) {
  return (
    <div className="flex-1 min-w-0 h-32 rounded-[12px] border border-[#42493e] bg-[#1d201c] flex flex-col justify-between p-[17px]">
      <div>
        <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] tracking-[0.6px] uppercase leading-tight">{label}</p>
        <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[28px] mt-1 leading-tight">{value}</p>
      </div>
      {sub && (
        <p className={`font-['Inter',sans-serif] font-bold text-[12px] ${subPositive ? "text-[#3b6934]" : "text-[#ffaac8]"}`}>{sub}</p>
      )}
    </div>
  );
}

function SectionLabel({ children, action, onAction }: { children: string; action?: string; onAction?: () => void }) {
  return (
    <div className="flex items-center justify-between w-full">
      <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] tracking-[1.3px] uppercase">{children}</p>
      {action && (
        <button onClick={onAction} className="font-['Inter',sans-serif] font-medium text-[#a1d494] text-[13px] tracking-[0.6px]">{action}</button>
      )}
    </div>
  );
}

function Badge({ type }: { type: string }) {
  const colors: Record<string, string> = {
    Competitive: "text-[#a1d494]",
    Casual: "text-[#ffaac8]",
    Practice: "text-[#c2c9bb]",
    Upcoming: "text-[#a1d494]",
    Completed: "text-[#c2c9bb]",
    Cancelled: "text-[#ffaac8]",
    Active: "text-[#a1d494]",
  };
  return <span className={`font-['Inter',sans-serif] font-bold text-[11px] ${colors[type] || "text-[#c2c9bb]"}`}>{type}</span>;
}

function Card({ children, className = "" }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={`bg-[#1d201c] border border-[#42493e] rounded-[12px] ${className}`}>
      {children}
    </div>
  );
}

function ResultBadge({ result }: { result: "W" | "L" | "D" }) {
  const cfg = { W: "bg-[#2d5a27] text-[#a1d494]", L: "bg-[#3d1f2a] text-[#ffaac8]", D: "bg-[#2a2d29] text-[#c2c9bb]" };
  return <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full ${cfg[result]}`}>{result}</span>;
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

const NAV_ITEMS = [
  { id: "dashboard" as Screen, label: "Home", icon: HomeIcon },
  { id: "sessions" as Screen, label: "Sessions", icon: SessionIcon },
  { id: "courts" as Screen, label: "Courts", icon: CourtIcon },
  { id: "tournaments" as Screen, label: "Tourneys", icon: TrophyIcon },
  { id: "analytics" as Screen, label: "More", icon: MoreIcon },
];

function HomeIcon({ active }: { active: boolean }) {
  return (
    <svg width="18" height="20" viewBox="0 0 18 20" fill="none">
      <path d="M1 7.5L9 1L17 7.5V18C17 18.5523 16.5523 19 16 19H12V13H6V19H2C1.44772 19 1 18.5523 1 18V7.5Z"
        stroke={active ? "#a1d494" : "#c2c9bb"} strokeWidth="1.5" fill={active ? "rgba(161,212,148,0.15)" : "none"} />
    </svg>
  );
}

function SessionIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <rect x="1" y="1" width="18" height="18" rx="3" stroke={c} strokeWidth="1.5" />
      <path d="M5 7h10M5 10h7M5 13h5" stroke={c} strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function CourtIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <rect x="1" y="3" width="18" height="14" rx="2" stroke={c} strokeWidth="1.5" />
      <line x1="10" y1="3" x2="10" y2="17" stroke={c} strokeWidth="1.5" />
      <circle cx="10" cy="10" r="3" stroke={c} strokeWidth="1.5" />
    </svg>
  );
}

function TrophyIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M6 2h8v8a4 4 0 01-8 0V2z" stroke={c} strokeWidth="1.5" />
      <path d="M2 4h4M14 4h4" stroke={c} strokeWidth="1.5" strokeLinecap="round" />
      <path d="M10 14v3M7 18h6" stroke={c} strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function MoreIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="18" height="5" viewBox="0 0 18 5" fill="none">
      <circle cx="2.5" cy="2.5" r="2" fill={c} />
      <circle cx="9" cy="2.5" r="2" fill={c} />
      <circle cx="15.5" cy="2.5" r="2" fill={c} />
    </svg>
  );
}

function BottomNav({ active, onNav }: { active: Screen; onNav: (s: Screen) => void }) {
  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 bg-[rgba(29,32,28,0.96)] backdrop-blur-lg border-t border-[#42493e]"
      style={{ maxWidth: 480, margin: "0 auto", left: "50%", transform: "translateX(-50%)", width: "100%" }}>
      <div className="flex items-center justify-around px-4 pt-2 pb-safe" style={{ paddingBottom: "max(8px, env(safe-area-inset-bottom))" }}>
        {NAV_ITEMS.map(({ id, label, icon: Icon }) => (
          <button key={id} onClick={() => onNav(id)}
            className="flex flex-col items-center gap-0.5 py-1 min-w-[56px]">
            <Icon active={active === id} />
            <span className={`font-['Inter',sans-serif] font-medium text-[11px] tracking-[0.4px] mt-0.5 ${active === id ? "text-[#a1d494]" : "text-[#c2c9bb]"}`}>
              {label}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}

// ─── Top App Bar ──────────────────────────────────────────────────────────────

function TopBar({ title, subtitle, onBack }: { title: string; subtitle?: string; onBack?: () => void }) {
  return (
    <div className="sticky top-0 z-40 bg-[rgba(17,20,16,0.88)] backdrop-blur-md border-b border-[#42493e]/50 px-4 lg:px-8 py-3 lg:py-4 flex items-center gap-3">
      {onBack && (
        <button onClick={onBack} className="text-[#c2c9bb] mr-1 lg:hidden">
          <svg width="10" height="16" viewBox="0 0 10 16" fill="none">
            <path d="M8 2L2 8L8 14" stroke="#c2c9bb" strokeWidth="1.8" strokeLinecap="round" />
          </svg>
        </button>
      )}
      <div className="flex-1">
        {subtitle && <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px]">{subtitle}</p>}
        <h1 className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[22px] lg:text-[28px] leading-tight">{title}</h1>
      </div>
    </div>
  );
}

// ─── Dashboard Screen ─────────────────────────────────────────────────────────

function Dashboard({ onNav }: { onNav: (s: Screen) => void }) {
  const totalHours = SESSIONS.reduce((acc, s) => {
    const [h, m] = s.duration.replace("h", "").replace("m", "").trim().split(" ");
    return acc + (parseInt(h) || 0) + (parseInt(m) || 0) / 60;
  }, 0);

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <div className="sticky top-0 z-40 bg-[rgba(17,20,16,0.88)] backdrop-blur-md border-b border-[#42493e]/50 px-4 lg:px-8 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="size-10 rounded-full bg-[#2d5a27] flex items-center justify-center text-[#a1d494] font-bold text-base border border-[#42493e]">J</div>
          <div>
            <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px]">Good morning,</p>
            <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[18px] leading-tight">John!</p>
          </div>
        </div>
        <button className="text-[#e2e3dc]">
          <svg width="20" height="22" viewBox="0 0 20 22" fill="none">
            <path d="M10 22c1.1 0 2-.9 2-2H8c0 1.1.9 2 2 2zm6-6V9c0-3.07-1.64-5.64-4.5-6.32V2C11.5 1.17 10.83.5 10 .5S8.5 1.17 8.5 2v.68C5.63 3.36 4 5.92 4 9v7l-2 2v1h16v-1l-2-2z"
              fill="#e2e3dc" />
          </svg>
        </button>
      </div>

      <div className="flex flex-col gap-6 px-4 lg:px-8 pt-5 pb-28 lg:pb-10">
        {/* Page Title */}
        <h2 className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[26px] lg:text-[32px] tracking-[-0.5px]">Dashboard</h2>

        {/* Stats Grid — 2 cols mobile, 4 cols desktop */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <StatCard label="Sessions This Week" value="8" sub="+14% vs last week" subPositive />
          <StatCard label="Hours Played" value={`${totalHours.toFixed(1)}h`} sub="11:30 left" subPositive />
          <StatCard label="Win Rate" value="75%" sub="+5% this month" subPositive />
          <StatCard label="Monthly Spend" value="$337" sub="+8% vs last month" subPositive={false} />
        </div>

        {/* Desktop: 2-col layout for court + reservation side by side */}
        <div className="lg:grid lg:grid-cols-2 lg:gap-6 flex flex-col gap-6">
          {/* Left column */}
          <div className="flex flex-col gap-6">
            {/* Monthly Spending */}
            <div className="bg-[#282b26] border border-[#42493e] rounded-[12px] overflow-hidden">
              <div className="px-4 pt-4 pb-2">
                <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[12px] tracking-[1.2px] uppercase mb-1">MONTHLY SPENDING</p>
                <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[32px] tracking-[-0.3px]">$337.40</p>
                <p className="font-['Inter',sans-serif] font-bold text-[#3b6934] text-[12px] mt-0.5">+8% vs last month</p>
              </div>
              <div className="h-20">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={spendingData} margin={{ top: 0, right: 0, bottom: 0, left: 0 }}>
                    <defs>
                      <linearGradient id="spendGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#a1d494" stopOpacity={0.3} />
                        <stop offset="100%" stopColor="#a1d494" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <Area type="monotone" dataKey="amount" stroke="#a1d494" strokeWidth={2} fill="url(#spendGrad)" dot={false} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Favorite Court */}
            <div className="flex flex-col gap-3">
              <SectionLabel action="View all" onAction={() => onNav("courts")}>FAVORITE COURT</SectionLabel>
          <Card>
            <div className="flex items-center justify-between p-[17px]">
              <div className="flex items-center gap-4">
                <div className="size-12 rounded-[8px] bg-[#2d5a27] flex items-center justify-center">
                  <CourtIcon active />
                </div>
                <div>
                  <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[18px]">Central Court</p>
                  <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] mt-0.5">Indoor • Pro Surface</p>
                </div>
              </div>
              <svg width="8" height="13" viewBox="0 0 8 13" fill="none">
                <path d="M1 1.5L6.5 6.5L1 11.5" stroke="#c2c9bb" strokeWidth="1.8" strokeLinecap="round" />
              </svg>
            </div>
          </Card>
            </div>

            {/* Next Reservation */}
            <div className="flex flex-col gap-3">
              <SectionLabel>NEXT RESERVATION</SectionLabel>
              <Card>
                <div className="flex items-center justify-between p-[17px]">
                  <div className="flex items-center gap-4">
                    <div className="size-12 rounded-[8px] bg-[#474649] flex items-center justify-center">
                      <svg width="18" height="20" viewBox="0 0 18 20" fill="none">
                        <path d="M1 5C1 3.89543 1.89543 3 3 3H15C16.1046 3 17 3.89543 17 5V17C17 18.1046 16.1046 19 15 19H3C1.89543 19 1 18.1046 1 17V5Z" stroke="#B6B4B7" strokeWidth="1.5" />
                        <path d="M1 8H17M6 1V5M12 1V5" stroke="#B6B4B7" strokeWidth="1.5" strokeLinecap="round" />
                      </svg>
                    </div>
                    <div>
                      <p className="font-['Inter',sans-serif] font-bold text-[#a1d494] text-[13px]">Tomorrow, 7:00 AM</p>
                      <p className="font-['Inter',sans-serif] font-normal text-[#c2c9bb] text-[15px]">Central Court</p>
                    </div>
                  </div>
                  <svg width="8" height="13" viewBox="0 0 8 13" fill="none">
                    <path d="M1 1.5L6.5 6.5L1 11.5" stroke="#c2c9bb" strokeWidth="1.8" strokeLinecap="round" />
                  </svg>
                </div>
              </Card>
            </div>

            {/* Quick actions */}
            <div className="flex gap-3">
              <button onClick={() => onNav("sessions")}
                className="flex-1 bg-[#a1d494] text-[#0a3909] font-['Montserrat',sans-serif] font-bold text-[14px] py-3 rounded-[12px]">
                + New Session
              </button>
              <button onClick={() => onNav("reservations")}
                className="flex-1 bg-[#1d201c] border border-[#42493e] text-[#e2e3dc] font-['Montserrat',sans-serif] font-bold text-[14px] py-3 rounded-[12px]">
                Book Court
              </button>
            </div>
          </div>{/* end left column */}

          {/* Right column — Recent Sessions */}
          <div className="flex flex-col gap-3">
            <SectionLabel action="View all" onAction={() => onNav("sessions")}>RECENT SESSIONS</SectionLabel>
            <Card className="divide-y divide-[#1c1c1e]">
              {SESSIONS.slice(0, 5).map((s) => (
                <div key={s.id} className="flex items-center justify-between py-4 px-4">
                  <div className="flex items-center gap-4">
                    <div className="size-10 rounded-full bg-[#333631] border border-[#42493e] flex items-center justify-center">
                      <ResultBadge result={s.result} />
                    </div>
                    <div>
                      <p className="font-['Inter',sans-serif] font-bold text-[#e2e3dc] text-[15px]">{s.date}</p>
                      <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px]">vs {s.opponent}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-['Inter',sans-serif] font-bold text-[#e2e3dc] text-[14px]">{s.score}</p>
                    <Badge type={s.type} />
                  </div>
                </div>
              ))}
            </Card>
          </div>{/* end right column */}
        </div>{/* end 2-col grid */}
      </div>
    </div>
  );
}

// ─── Sessions Screen ──────────────────────────────────────────────────────────

function Sessions({ onBack }: { onBack: () => void }) {
  const [filter, setFilter] = useState<"All" | "Competitive" | "Casual" | "Practice">("All");
  const [showForm, setShowForm] = useState(false);

  const filtered = filter === "All" ? SESSIONS : SESSIONS.filter(s => s.type === filter);

  const wins = SESSIONS.filter(s => s.result === "W").length;
  const totalSessions = SESSIONS.length;
  const winRate = Math.round((wins / totalSessions) * 100);

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="Sessions" subtitle={`${totalSessions} total`} />

      <div className="flex flex-col gap-5 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
        {/* Stats Row */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-4">
            <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[12px] uppercase tracking-wider mb-1">Win Rate</p>
            <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[28px]">{winRate}%</p>
          </div>
          <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-4">
            <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[12px] uppercase tracking-wider mb-1">Avg Duration</p>
            <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[28px]">1h 28m</p>
          </div>
          <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-4">
            <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[12px] uppercase tracking-wider mb-1">Total Sessions</p>
            <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[28px]">{totalSessions}</p>
          </div>
          <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-4">
            <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[12px] uppercase tracking-wider mb-1">Best Streak</p>
            <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[28px]">4W</p>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="flex gap-2 overflow-x-auto pb-1">
          {(["All", "Competitive", "Casual", "Practice"] as const).map(f => (
            <button key={f} onClick={() => setFilter(f)}
              className={`flex-shrink-0 px-4 py-2 rounded-full text-[13px] font-medium border transition-colors ${filter === f ? "bg-[#a1d494] text-[#0a3909] border-[#a1d494]" : "bg-[#1d201c] text-[#c2c9bb] border-[#42493e]"}`}>
              {f}
            </button>
          ))}
        </div>

        {/* Session List */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-3">
          {filtered.map(s => (
            <Card key={s.id} className="p-4">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className={`size-10 rounded-full flex items-center justify-center font-bold text-[13px] ${s.result === "W" ? "bg-[#2d5a27] text-[#a1d494]" : s.result === "L" ? "bg-[#3d1f2a] text-[#ffaac8]" : "bg-[#333631] text-[#c2c9bb]"}`}>
                    {s.result}
                  </div>
                  <div>
                    <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[15px]">{s.date}</p>
                    <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px] mt-0.5">{s.court}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="font-['Inter',sans-serif] font-bold text-[#e2e3dc] text-[14px]">{s.score}</p>
                  <Badge type={s.type} />
                </div>
              </div>
              {s.opponent !== "Solo Drill" && (
                <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px] mt-2">vs {s.opponent} · {s.duration}</p>
              )}
            </Card>
          ))}
        </div>
      </div>

      {/* FAB */}
      <button onClick={() => setShowForm(true)}
        className="fixed bottom-24 lg:bottom-8 right-5 lg:right-8 size-14 rounded-full bg-[#a1d494] flex items-center justify-center shadow-[0_10px_40px_rgba(0,0,0,0.4)] z-50">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <path d="M10 3v14M3 10h14" stroke="#0a3909" strokeWidth="2.2" strokeLinecap="round" />
        </svg>
      </button>

      {showForm && <NewSessionModal onClose={() => setShowForm(false)} />}
    </div>
  );
}

function NewSessionModal({ onClose }: { onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-[100] flex items-end">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />
      <div className="relative w-full bg-[#1d201c] border-t border-[#42493e] rounded-t-[24px] p-6 pb-10 max-h-[85vh] overflow-y-auto">
        <div className="w-10 h-1 bg-[#42493e] rounded-full mx-auto mb-5" />
        <h3 className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[20px] mb-5">New Session</h3>
        <div className="flex flex-col gap-4">
          {[
            { label: "Court", placeholder: "Select court" },
            { label: "Opponents", placeholder: "Enter opponent names" },
            { label: "Score", placeholder: "e.g. W 11-7, 11-9" },
            { label: "Duration", placeholder: "e.g. 1h 30m" },
            { label: "Notes", placeholder: "Optional notes…" },
          ].map(({ label, placeholder }) => (
            <div key={label}>
              <label className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] block mb-1.5">{label}</label>
              <input placeholder={placeholder}
                className="w-full bg-[#282b26] border border-[#42493e] rounded-[10px] px-3 py-3 text-[#e2e3dc] text-[15px] placeholder:text-[#42493e] outline-none focus:border-[#a1d494] transition-colors" />
            </div>
          ))}
          <button onClick={onClose}
            className="w-full bg-[#a1d494] text-[#0a3909] font-['Montserrat',sans-serif] font-bold text-[15px] py-4 rounded-[12px] mt-2">
            Save Session
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Courts Screen ────────────────────────────────────────────────────────────

function Courts({ onBack }: { onBack: () => void }) {
  const [showForm, setShowForm] = useState(false);

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="Courts" subtitle="My locations" />

      <div className="flex flex-col gap-4 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {COURTS.map(court => (
          <Card key={court.id} className="p-4">
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-3">
                <div className={`size-12 rounded-[10px] flex items-center justify-center ${court.favorite ? "bg-[#2d5a27]" : "bg-[#282b26]"}`}>
                  <CourtIcon active={court.favorite} />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[17px]">{court.name}</p>
                    {court.favorite && (
                      <span className="text-[11px] bg-[#2d5a27] text-[#a1d494] px-2 py-0.5 rounded-full font-bold">Favorite</span>
                    )}
                  </div>
                  <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px] mt-0.5">{court.type} · {court.surface}</p>
                  <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px] mt-0.5">{court.location}</p>
                </div>
              </div>
            </div>
            <div className="flex gap-6 mt-4 pt-3 border-t border-[#42493e]/60">
              <div>
                <p className="font-['Inter',sans-serif] text-[#8c9387] text-[11px] uppercase tracking-wider">Played</p>
                <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[18px]">{court.timesPlayed}x</p>
              </div>
              <div>
                <p className="font-['Inter',sans-serif] text-[#8c9387] text-[11px] uppercase tracking-wider">Last Visit</p>
                <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] mt-1">{court.lastPlayed}</p>
              </div>
            </div>
          </Card>
        ))}

        </div>
        <button onClick={() => setShowForm(true)}
          className="w-full py-4 border border-dashed border-[#42493e] rounded-[12px] text-[#c2c9bb] font-['Inter',sans-serif] font-medium text-[14px] flex items-center justify-center gap-2">
          <span className="text-[#a1d494] text-xl font-bold">+</span> Add Court
        </button>
      </div>
    </div>
  );
}

// ─── Reservations Screen ──────────────────────────────────────────────────────

function Reservations({ onBack }: { onBack: () => void }) {
  const [activeTab, setActiveTab] = useState<"upcoming" | "history">("upcoming");
  const [showForm, setShowForm] = useState(false);

  const upcoming = RESERVATIONS.filter(r => r.status === "Upcoming");
  const history = RESERVATIONS.filter(r => r.status !== "Upcoming");

  const statusBg: Record<string, string> = {
    Upcoming: "bg-[#2d5a27] text-[#a1d494]",
    Completed: "bg-[#282b26] text-[#c2c9bb]",
    Cancelled: "bg-[#3d1f2a] text-[#ffaac8]",
  };

  const items = activeTab === "upcoming" ? upcoming : history;

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="Reservations" />

      {/* Tabs */}
      <div className="flex border-b border-[#42493e]">
        {(["upcoming", "history"] as const).map(tab => (
          <button key={tab} onClick={() => setActiveTab(tab)}
            className={`flex-1 py-3 font-['Inter',sans-serif] font-medium text-[14px] capitalize tracking-[0.6px] relative ${activeTab === tab ? "text-[#a1d494]" : "text-[#c2c9bb]"}`}>
            {tab}
            {activeTab === tab && <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#a1d494]" />}
          </button>
        ))}
      </div>

      <div className="flex flex-col gap-4 px-4 lg:px-8 pt-4 pb-28 lg:pb-10 lg:flex-row lg:items-start lg:gap-6">
        {/* Mini Calendar — fixed width on desktop */}
        <div className="lg:w-80 lg:flex-shrink-0">
        {/* Mini Calendar */}
        <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-4">
          <div className="flex items-center justify-between mb-4">
            <button className="text-[#c2c9bb] p-1">
              <svg width="8" height="13" viewBox="0 0 8 13" fill="none"><path d="M7 1.5L1.5 6.5L7 11.5" stroke="#c2c9bb" strokeWidth="1.8" strokeLinecap="round" /></svg>
            </button>
            <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[18px]">June 2025</p>
            <button className="text-[#c2c9bb] p-1">
              <svg width="8" height="13" viewBox="0 0 8 13" fill="none"><path d="M1 1.5L6.5 6.5L1 11.5" stroke="#c2c9bb" strokeWidth="1.8" strokeLinecap="round" /></svg>
            </button>
          </div>
          <div className="grid grid-cols-7 gap-1">
            {["S", "M", "T", "W", "T", "F", "S"].map((d, i) => (
              <p key={i} className="text-center font-['Inter',sans-serif] font-medium text-[#8c9387] text-[13px] py-1">{d}</p>
            ))}
            {[null, null, null, null, null, null, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30].map((day, i) => (
              <div key={i} className={`aspect-square flex items-center justify-center rounded-full text-[14px] font-['Inter',sans-serif] cursor-pointer
                ${day === 20 ? "bg-[#a1d494] text-[#0a3909] font-bold" : ""}
                ${day === 21 || day === 24 ? "bg-[#2d5a27] text-[#a1d494] font-medium" : ""}
                ${day && day !== 20 && day !== 21 && day !== 24 ? "text-[#e2e3dc]" : ""}
                ${!day ? "pointer-events-none" : "hover:bg-[#282b26]"}
              `}>
                {day}
              </div>
            ))}
          </div>
        </div>
        </div>{/* end calendar column */}

        {/* Reservation List — right column on desktop */}
        <div className="flex flex-col gap-3 lg:flex-1">
          {items.map(r => (
            <Card key={r.id} className="p-4">
              <div className="flex items-start justify-between">
                <div>
                  <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[17px]">{r.court}</p>
                  <p className="font-['Inter',sans-serif] font-bold text-[#a1d494] text-[13px] mt-1">{r.date}</p>
                  <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px]">{r.startTime} – {r.endTime}</p>
                  {r.notes && <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px] mt-1">{r.notes}</p>}
                </div>
                <span className={`text-[11px] font-bold px-2.5 py-1 rounded-full ${statusBg[r.status]}`}>{r.status}</span>
              </div>
            </Card>
          ))}

          {items.length === 0 && (
            <div className="text-center py-12">
              <p className="font-['Inter',sans-serif] text-[#8c9387] text-[15px]">No {activeTab} reservations</p>
            </div>
          )}
        </div>
      </div>

      <button onClick={() => setShowForm(true)}
        className="fixed bottom-24 lg:bottom-8 right-5 lg:right-8 size-14 rounded-full bg-[#a1d494] flex items-center justify-center shadow-[0_10px_40px_rgba(0,0,0,0.4)] z-50">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <path d="M10 3v14M3 10h14" stroke="#0a3909" strokeWidth="2.2" strokeLinecap="round" />
        </svg>
      </button>
    </div>
  );
}

// ─── Tournament Format Types ──────────────────────────────────────────────────

const TOURNAMENT_FORMATS = [
  {
    id: "Single Elimination" as const,
    label: "Single Elimination",
    tag: "Most Common",
    icon: (
      <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
        <rect x="1" y="4" width="8" height="5" rx="1.5" stroke="#a1d494" strokeWidth="1.5" />
        <rect x="1" y="12" width="8" height="5" rx="1.5" stroke="#a1d494" strokeWidth="1.5" />
        <rect x="1" y="20" width="8" height="5" rx="1.5" stroke="#a1d494" strokeWidth="1.5" />
        <rect x="1" y="4" width="8" height="5" rx="1.5" stroke="#a1d494" strokeWidth="1.5" />
        <rect x="11" y="8" width="8" height="5" rx="1.5" stroke="#a1d494" strokeWidth="1.5" />
        <rect x="11" y="20" width="8" height="5" rx="1.5" stroke="#a1d494" strokeWidth="1.5" />
        <rect x="21" y="14" width="6" height="5" rx="1.5" stroke="#a1d494" strokeWidth="1.5" />
        <path d="M9 6.5h2M9 14.5h2M9 22.5v-4h2M19 10.5h2M19 22.5v-5h2" stroke="#a1d494" strokeWidth="1.2" strokeLinecap="round" />
      </svg>
    ),
    description: "One loss and you're out. The fastest format — perfect for day-of tournaments.",
    rules: [
      "Players/teams are seeded into a bracket",
      "Lose once → eliminated immediately",
      "Games to 11, win by 2 (standard pickleball)",
      "Final and semi-finals may play best-of-3",
      "Winner advances; bracket shrinks each round",
    ],
    bestFor: "4 – 32 players · Quick events",
    rounds: (n: number) => Math.ceil(Math.log2(n)),
  },
  {
    id: "Double Elimination" as const,
    label: "Double Elimination",
    tag: "Fairest",
    icon: (
      <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
        <rect x="1" y="2" width="7" height="4.5" rx="1.2" stroke="#a1d494" strokeWidth="1.4" />
        <rect x="1" y="8" width="7" height="4.5" rx="1.2" stroke="#a1d494" strokeWidth="1.4" />
        <rect x="10" y="5" width="7" height="4.5" rx="1.2" stroke="#a1d494" strokeWidth="1.4" />
        <rect x="10" y="14" width="7" height="4.5" rx="1.2" stroke="#a1d494" strokeWidth="1.4" />
        <rect x="19" y="9" width="8" height="4.5" rx="1.2" stroke="#a1d494" strokeWidth="1.4" />
        <rect x="1" y="16" width="7" height="4.5" rx="1.2" stroke="#c2c9bb" strokeWidth="1.4" strokeDasharray="2 1.5" />
        <rect x="1" y="22" width="7" height="4.5" rx="1.2" stroke="#c2c9bb" strokeWidth="1.4" strokeDasharray="2 1.5" />
        <rect x="10" y="20" width="7" height="4.5" rx="1.2" stroke="#c2c9bb" strokeWidth="1.4" strokeDasharray="2 1.5" />
        <path d="M8 4h2M8 10h2M17 7h2M17 16h2" stroke="#a1d494" strokeWidth="1.2" strokeLinecap="round" />
      </svg>
    ),
    description: "Two losses to be eliminated. Gives every player a second chance via the losers bracket.",
    rules: [
      "Winners bracket: standard single elim path",
      "Losers bracket: second chance after first loss",
      "Lose twice → eliminated",
      "Winners & Losers bracket champions meet in the Grand Final",
      "Grand Final: if Losers bracket winner wins, a reset match is played",
    ],
    bestFor: "8 – 16 players · Half-day events",
    rounds: (n: number) => Math.ceil(Math.log2(n)) * 2 - 1,
  },
  {
    id: "Round Robin" as const,
    label: "Round Robin",
    tag: "Most Play",
    icon: (
      <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
        <circle cx="14" cy="14" r="9" stroke="#a1d494" strokeWidth="1.5" />
        <circle cx="14" cy="5" r="2.5" fill="#a1d494" />
        <circle cx="22.5" cy="19" r="2.5" fill="#a1d494" />
        <circle cx="5.5" cy="19" r="2.5" fill="#a1d494" />
        <path d="M14 7v-0M20.8 17.5l-0 0M7.2 17.5l0 0" stroke="#0a3909" strokeWidth="1.2" strokeLinecap="round" />
        <path d="M14 7.5L20.5 17M14 7.5L7.5 17M20.5 17H7.5" stroke="#a1d494" strokeWidth="1.2" strokeLinecap="round" />
      </svg>
    ),
    description: "Everyone plays everyone. Standings determine the champion — maximum games guaranteed.",
    rules: [
      "Every player/team plays all others once",
      "Points: Win = 2 pts, Draw = 1 pt, Loss = 0 pts",
      "Tiebreakers: head-to-head → point differential",
      "Games to 11, win by 2",
      "Optional playoffs for top 2–4 after pool play",
    ],
    bestFor: "4 – 10 players · Social/league play",
    rounds: (n: number) => n - 1,
  },
] as const;

type FormatId = typeof TOURNAMENT_FORMATS[number]["id"];

// ─── Create Tournament Flow ───────────────────────────────────────────────────

interface CreateState {
  step: "type" | "setup" | "players" | "bracket";
  format: FormatId | null;
  name: string;
  date: string;
  location: string;
  entryFee: string;
  players: string[];
  newPlayer: string;
  winners: Record<string, string>; // matchKey → winner name
}

function generateSEBracket(players: string[]) {
  // Pad to next power of 2 with byes
  const size = Math.pow(2, Math.ceil(Math.log2(Math.max(players.length, 2))));
  const seeded = [...players];
  while (seeded.length < size) seeded.push("BYE");

  const rounds: [string, string][][] = [];
  let current = seeded;
  while (current.length > 1) {
    const pairs: [string, string][] = [];
    for (let i = 0; i < current.length; i += 2) {
      pairs.push([current[i], current[i + 1]]);
    }
    rounds.push(pairs);
    current = current.map((_, i) => (i % 2 === 0 ? "?" : null)).filter(Boolean) as string[];
  }
  return rounds;
}

function generateRRSchedule(players: string[]) {
  const matches: [string, string][] = [];
  for (let i = 0; i < players.length; i++) {
    for (let j = i + 1; j < players.length; j++) {
      matches.push([players[i], players[j]]);
    }
  }
  return matches;
}

function CreateTournament({ onBack, onDone }: { onBack: () => void; onDone: () => void }) {
  const [state, setState] = useState<CreateState>({
    step: "type",
    format: null,
    name: "",
    date: "",
    location: "",
    entryFee: "",
    players: ["You"],
    newPlayer: "",
    winners: {},
  });

  const set = (patch: Partial<CreateState>) => setState(s => ({ ...s, ...patch }));

  function addPlayer() {
    const name = state.newPlayer.trim();
    if (!name || state.players.includes(name)) return;
    set({ players: [...state.players, name], newPlayer: "" });
  }

  function removePlayer(name: string) {
    if (name === "You") return;
    set({ players: state.players.filter(p => p !== name) });
  }

  function recordWinner(key: string, winner: string) {
    set({ winners: { ...state.winners, [key]: winner } });
  }

  const fmt = TOURNAMENT_FORMATS.find(f => f.id === state.format);

  // ── Step: Type Selection ──
  if (state.step === "type") {
    return (
      <div className="flex flex-col min-h-full">
        <TopBar title="Choose Format" subtitle="New tournament" onBack={onBack} />
        <div className="flex flex-col gap-4 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
          <p className="font-['Inter',sans-serif] text-[#8c9387] text-[14px]">Select a tournament format. Each plays differently — choose what suits your group.</p>

          {TOURNAMENT_FORMATS.map(f => (
            <button key={f.id} onClick={() => set({ format: f.id, step: "setup" })} className="text-left">
              <div className={`border rounded-[14px] p-4 transition-all ${state.format === f.id ? "border-[#a1d494] bg-[#1d2a1c]" : "border-[#42493e] bg-[#1d201c]"}`}>
                {/* Header row */}
                <div className="flex items-start gap-3 mb-3">
                  <div className="size-12 rounded-[10px] bg-[#111410] border border-[#42493e] flex items-center justify-center flex-shrink-0">
                    {f.icon}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[16px]">{f.label}</p>
                      <span className="text-[10px] font-bold bg-[#2d5a27] text-[#a1d494] px-2 py-0.5 rounded-full">{f.tag}</span>
                    </div>
                    <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px] mt-1 leading-snug">{f.description}</p>
                  </div>
                </div>

                {/* Rules */}
                <div className="border-t border-[#42493e]/60 pt-3 mb-3 flex flex-col gap-1.5">
                  {f.rules.map((r, i) => (
                    <div key={i} className="flex items-start gap-2">
                      <span className="text-[#a1d494] font-bold text-[11px] mt-0.5 flex-shrink-0">→</span>
                      <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[12px] leading-snug">{r}</p>
                    </div>
                  ))}
                </div>

                {/* Footer */}
                <div className="flex items-center justify-between">
                  <p className="font-['Inter',sans-serif] text-[#8c9387] text-[11px]">{f.bestFor}</p>
                  <div className="flex items-center gap-1 text-[#a1d494]">
                    <p className="font-['Inter',sans-serif] font-bold text-[12px]">Select</p>
                    <svg width="7" height="11" viewBox="0 0 7 11" fill="none">
                      <path d="M1 1L5.5 5.5L1 10" stroke="#a1d494" strokeWidth="1.6" strokeLinecap="round" />
                    </svg>
                  </div>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    );
  }

  // ── Step: Setup Details ──
  if (state.step === "setup") {
    return (
      <div className="flex flex-col min-h-full">
        <TopBar title="Tournament Details" subtitle={fmt?.label} onBack={() => set({ step: "type" })} />
        <div className="flex flex-col gap-5 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">

          {/* Format reminder badge */}
          <div className="flex items-center gap-3 bg-[#1d2a1c] border border-[#a1d494]/30 rounded-[12px] p-3">
            <div className="size-9 rounded-[8px] bg-[#111410] border border-[#42493e] flex items-center justify-center flex-shrink-0">
              {fmt?.icon}
            </div>
            <div>
              <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[14px]">{fmt?.label}</p>
              <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px]">{fmt?.bestFor}</p>
            </div>
            <button onClick={() => set({ step: "type" })} className="ml-auto font-['Inter',sans-serif] text-[#c2c9bb] text-[12px] underline">Change</button>
          </div>

          {[
            { label: "Tournament Name", key: "name", placeholder: "e.g. Summer Smash 2025" },
            { label: "Date", key: "date", placeholder: "e.g. Jul 20, 2025" },
            { label: "Location", key: "location", placeholder: "e.g. Central Court Complex" },
            { label: "Entry Fee ($)", key: "entryFee", placeholder: "0 for free" },
          ].map(({ label, key, placeholder }) => (
            <div key={key}>
              <label className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] block mb-1.5">{label}</label>
              <input
                value={(state as Record<string, string>)[key]}
                onChange={e => set({ [key]: e.target.value } as Partial<CreateState>)}
                placeholder={placeholder}
                className="w-full bg-[#282b26] border border-[#42493e] rounded-[10px] px-3 py-3 text-[#e2e3dc] text-[15px] placeholder:text-[#42493e] outline-none focus:border-[#a1d494] transition-colors"
              />
            </div>
          ))}

          <button
            onClick={() => set({ step: "players" })}
            disabled={!state.name.trim()}
            className="w-full bg-[#a1d494] text-[#0a3909] font-['Montserrat',sans-serif] font-bold text-[15px] py-4 rounded-[12px] disabled:opacity-40">
            Next: Add Players →
          </button>
        </div>
      </div>
    );
  }

  // ── Step: Add Players ──
  if (state.step === "players") {
    const minPlayers = state.format === "Round Robin" ? 3 : 4;
    const ready = state.players.length >= minPlayers;

    return (
      <div className="flex flex-col min-h-full">
        <TopBar title="Add Players" subtitle={`${state.players.length} added`} onBack={() => set({ step: "setup" })} />
        <div className="flex flex-col gap-5 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">

          <p className="font-['Inter',sans-serif] text-[#8c9387] text-[13px]">
            Minimum {minPlayers} players for {fmt?.label}. For Single/Double Elimination, bracket sizes are padded to the nearest power of 2 with byes.
          </p>

          {/* Player input */}
          <div className="flex gap-2">
            <input
              value={state.newPlayer}
              onChange={e => set({ newPlayer: e.target.value })}
              onKeyDown={e => e.key === "Enter" && addPlayer()}
              placeholder="Player name…"
              className="flex-1 bg-[#282b26] border border-[#42493e] rounded-[10px] px-3 py-3 text-[#e2e3dc] text-[15px] placeholder:text-[#42493e] outline-none focus:border-[#a1d494] transition-colors"
            />
            <button onClick={addPlayer} className="size-12 bg-[#a1d494] rounded-[10px] flex items-center justify-center flex-shrink-0">
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                <path d="M9 2v14M2 9h14" stroke="#0a3909" strokeWidth="2" strokeLinecap="round" />
              </svg>
            </button>
          </div>

          {/* Player list */}
          <div className="flex flex-col gap-2">
            {state.players.map((name, i) => (
              <div key={name} className="flex items-center justify-between bg-[#1d201c] border border-[#42493e] rounded-[10px] px-4 py-3">
                <div className="flex items-center gap-3">
                  <div className={`size-8 rounded-full flex items-center justify-center text-[12px] font-bold ${name === "You" ? "bg-[#2d5a27] text-[#a1d494]" : "bg-[#282b26] text-[#c2c9bb]"}`}>
                    {name === "You" ? "★" : `${i + 1}`}
                  </div>
                  <p className={`font-['Inter',sans-serif] font-medium text-[15px] ${name === "You" ? "text-[#a1d494]" : "text-[#e2e3dc]"}`}>{name}</p>
                  {name === "You" && <span className="text-[10px] text-[#8c9387] font-medium">(you)</span>}
                </div>
                {name !== "You" && (
                  <button onClick={() => removePlayer(name)} className="size-7 flex items-center justify-center rounded-full bg-[#3d1f2a] text-[#ffaac8] text-[14px] font-bold">×</button>
                )}
              </div>
            ))}
          </div>

          {/* Predicted rounds info */}
          {state.players.length >= 2 && (
            <div className="bg-[#282b26] border border-[#42493e] rounded-[12px] p-4">
              <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px]">
                <span className="font-bold text-[#e2e3dc]">{state.players.length} players</span> · {" "}
                {state.format === "Round Robin"
                  ? `${(state.players.length * (state.players.length - 1)) / 2} total matches`
                  : `${fmt?.rounds(state.players.length)} rounds`
                }
                {state.format === "Double Elimination" && " (winners + losers)"}
              </p>
            </div>
          )}

          <button
            onClick={() => set({ step: "bracket" })}
            disabled={!ready}
            className="w-full bg-[#a1d494] text-[#0a3909] font-['Montserrat',sans-serif] font-bold text-[15px] py-4 rounded-[12px] disabled:opacity-40">
            {ready ? "Generate Bracket →" : `Need ${minPlayers - state.players.length} more player${minPlayers - state.players.length > 1 ? "s" : ""}`}
          </button>
        </div>
      </div>
    );
  }

  // ── Step: Bracket View ──
  if (state.step === "bracket") {
    if (state.format === "Round Robin") {
      return <RRBracket state={state} onBack={() => set({ step: "players" })} onWin={recordWinner} onDone={onDone} />;
    }
    return <SEBracket state={state} onBack={() => set({ step: "players" })} onWin={recordWinner} onDone={onDone} isDouble={state.format === "Double Elimination"} />;
  }

  return null;
}

// ── Single / Double Elimination Bracket ──

function SEBracket({ state, onBack, onWin, onDone, isDouble }: {
  state: CreateState; onBack: () => void;
  onWin: (key: string, w: string) => void; onDone: () => void;
  isDouble: boolean;
}) {
  const rounds = generateSEBracket(state.players);
  const roundLabels = ["Round 1", "QF", "SF", "Final", "Grand Final"];

  function getLabel(roundIdx: number, total: number) {
    if (roundIdx === total - 1) return "Final";
    if (roundIdx === total - 2) return "Semi-Final";
    if (roundIdx === total - 3) return "Quarter-Final";
    return `Round ${roundIdx + 1}`;
  }

  // Compute live bracket — advance winners through rounds
  const live: string[][] = [state.players.concat()];
  const size = Math.pow(2, Math.ceil(Math.log2(Math.max(state.players.length, 2))));
  const seeded = [...state.players];
  while (seeded.length < size) seeded.push("BYE");

  const liveRounds: [string, string][][] = [];
  let current = [...seeded];
  while (current.length > 1) {
    const pairs: [string, string][] = [];
    for (let i = 0; i < current.length; i += 2) pairs.push([current[i], current[i + 1]]);
    liveRounds.push(pairs);
    const nextRound: string[] = [];
    pairs.forEach((pair, pi) => {
      const key = `r${liveRounds.length - 1}m${pi}`;
      const w = state.winners[key];
      nextRound.push(w || (pair[1] === "BYE" ? pair[0] : "?"));
    });
    current = nextRound;
  }

  const champion = state.winners[`r${liveRounds.length - 1}m0`] ?? null;

  const totalRounds = liveRounds.length;
  const CARD_W = 108;
  const CARD_H = 64;
  const V_GAP = 12;
  const COL_GAP = 28;

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title={state.name || "My Tournament"} subtitle={`${isDouble ? "Double" : "Single"} Elimination · ${state.players.length} players`} onBack={onBack} />

      <div className="flex flex-col gap-5 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
        {champion && (
          <div className="bg-[#1d2a1c] border border-[#a1d494]/50 rounded-[14px] p-4 flex items-center gap-3">
            <div className="size-10 bg-[#a1d494] rounded-full flex items-center justify-center">
              <TrophyIcon active={false} />
            </div>
            <div>
              <p className="font-['Inter',sans-serif] text-[#8c9387] text-[11px] uppercase tracking-wider">Champion</p>
              <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[20px]">{champion}</p>
            </div>
          </div>
        )}

        {isDouble && (
          <div className="bg-[#282b26] border border-[#42493e] rounded-[12px] p-3">
            <p className="font-['Inter',sans-serif] font-bold text-[#c2c9bb] text-[12px] mb-1">Double Elimination</p>
            <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px]">Tap a player in any match to mark them as winner. Losers drop to the Losers Bracket (shown below).</p>
          </div>
        )}

        {/* Horizontal scroll bracket */}
        <div>
          <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] uppercase tracking-[1.2px] mb-3">
            {isDouble ? "Winners Bracket" : "Bracket"}
          </p>
          <div className="overflow-x-auto pb-3">
            <div className="flex gap-0" style={{ minWidth: totalRounds * (CARD_W + COL_GAP) }}>
              {liveRounds.map((pairs, ri) => {
                const spacing = Math.pow(2, ri);
                const topPad = ri === 0 ? 0 : (Math.pow(2, ri - 1) * (CARD_H + V_GAP)) / 2;

                return (
                  <div key={ri} className="flex flex-col flex-shrink-0" style={{ width: CARD_W, marginRight: ri < totalRounds - 1 ? COL_GAP : 0 }}>
                    <p className="font-['Inter',sans-serif] text-[#8c9387] text-[10px] uppercase tracking-wider mb-2">
                      {getLabel(ri, totalRounds)}
                    </p>
                    <div className="flex flex-col" style={{ gap: ri === 0 ? V_GAP : (spacing - 1) * (CARD_H + V_GAP) + V_GAP }}>
                      {pairs.map(([p1, p2], pi) => {
                        const key = `r${ri}m${pi}`;
                        const winner = state.winners[key];
                        const isBye = p2 === "BYE";

                        return (
                          <div key={pi} className="rounded-[10px] overflow-hidden border" style={{ borderColor: winner ? "#a1d494" : "#42493e" }}>
                            {[p1, p2].map((name, ni) => {
                              const isWinner = winner === name;
                              const isLoser = winner && winner !== name;
                              const isPending = name === "?";
                              const isByeSlot = name === "BYE";
                              return (
                                <button
                                  key={ni}
                                  disabled={isPending || isByeSlot || !!winner}
                                  onClick={() => !isPending && !isByeSlot && !winner && onWin(key, name)}
                                  className={`w-full px-3 py-2.5 text-left flex items-center gap-2 transition-colors
                                    ${ni === 0 ? "border-b border-[#42493e]" : ""}
                                    ${isWinner ? "bg-[#2d5a27]" : ""}
                                    ${isLoser ? "bg-[#111410] opacity-50" : ""}
                                    ${!winner && !isPending && !isByeSlot ? "active:bg-[#282b26]" : ""}
                                    ${isByeSlot ? "bg-[#111410]" : "bg-[#1d201c]"}
                                  `}
                                  style={{ minHeight: 30 }}
                                >
                                  {isWinner && <span className="text-[#a1d494] text-[10px]">✓</span>}
                                  <p className={`font-['Inter',sans-serif] text-[12px] font-medium truncate
                                    ${name === "You" && !isLoser ? "text-[#a1d494]" : ""}
                                    ${isByeSlot ? "text-[#42493e] italic" : ""}
                                    ${isPending ? "text-[#42493e]" : ""}
                                    ${isLoser ? "text-[#42493e]" : ""}
                                    ${!isPending && !isByeSlot && !isLoser && name !== "You" ? "text-[#c2c9bb]" : ""}
                                  `}>
                                    {isByeSlot ? "— BYE —" : name}
                                  </p>
                                </button>
                              );
                            })}
                          </div>
                        );
                      })}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Losers bracket for double elim (simplified) */}
        {isDouble && (
          <div>
            <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] uppercase tracking-[1.2px] mb-3">Losers Bracket</p>
            <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-4">
              <p className="font-['Inter',sans-serif] text-[#8c9387] text-[13px]">Players who lose in the Winners Bracket drop here for a second chance. The Losers Bracket champion faces the Winners Bracket champion in the Grand Final.</p>
              <div className="mt-3 flex flex-wrap gap-2">
                {Object.entries(state.winners)
                  .map(([key, winner]) => {
                    const [, ri, , pi] = key.match(/r(\d+)m(\d+)/) || [];
                    const roundPairs = liveRounds[parseInt(ri)];
                    if (!roundPairs) return null;
                    const pair = roundPairs[parseInt(pi)];
                    if (!pair) return null;
                    const loser = pair.find(p => p !== winner && p !== "BYE" && p !== "?");
                    return loser || null;
                  })
                  .filter(Boolean)
                  .map(loser => (
                    <div key={loser} className="px-3 py-1.5 bg-[#282b26] border border-[#42493e] rounded-full text-[#c2c9bb] font-['Inter',sans-serif] text-[12px]">
                      {loser}
                    </div>
                  ))}
                {Object.keys(state.winners).length === 0 && (
                  <p className="text-[#42493e] font-['Inter',sans-serif] text-[12px] italic">No losers yet — play some matches above</p>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Players */}
        <div>
          <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] uppercase tracking-[1.2px] mb-3">Players ({state.players.length})</p>
          <div className="flex flex-wrap gap-2">
            {state.players.map(name => (
              <div key={name} className={`px-3 py-1.5 rounded-full text-[12px] font-medium border ${name === "You" ? "bg-[#2d5a27] text-[#a1d494] border-[#a1d494]/30" : "bg-[#1d201c] text-[#c2c9bb] border-[#42493e]"}`}>
                {name}
              </div>
            ))}
          </div>
        </div>

        <button onClick={onDone} className="w-full bg-[#1d201c] border border-[#42493e] text-[#c2c9bb] font-['Montserrat',sans-serif] font-bold text-[14px] py-4 rounded-[12px]">
          Save & Finish
        </button>
      </div>
    </div>
  );
}

// ── Round Robin Bracket ──

function RRBracket({ state, onBack, onWin, onDone }: {
  state: CreateState; onBack: () => void;
  onWin: (key: string, w: string) => void; onDone: () => void;
}) {
  const matches = generateRRSchedule(state.players);

  const points: Record<string, number> = {};
  state.players.forEach(p => { points[p] = 0; });
  matches.forEach(([p1, p2], i) => {
    const w = state.winners[`rr${i}`];
    if (w) {
      points[w] = (points[w] || 0) + 2;
      const loser = w === p1 ? p2 : p1;
      // loser gets 0 already
    }
  });

  const standings = [...state.players].sort((a, b) => (points[b] || 0) - (points[a] || 0));
  const played = Object.keys(state.winners).length;
  const champion = played === matches.length ? standings[0] : null;

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title={state.name || "My Tournament"} subtitle={`Round Robin · ${state.players.length} players`} onBack={onBack} />

      <div className="flex flex-col gap-5 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
        {champion && (
          <div className="bg-[#1d2a1c] border border-[#a1d494]/50 rounded-[14px] p-4 flex items-center gap-3">
            <div className="size-10 bg-[#a1d494] rounded-full flex items-center justify-center">
              <TrophyIcon active={false} />
            </div>
            <div>
              <p className="font-['Inter',sans-serif] text-[#8c9387] text-[11px] uppercase tracking-wider">Champion</p>
              <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[20px]">{champion}</p>
            </div>
          </div>
        )}

        {/* Standings */}
        <div>
          <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] uppercase tracking-[1.2px] mb-3">Standings</p>
          <div className="flex flex-col gap-2">
            {standings.map((name, rank) => (
              <div key={name} className={`flex items-center justify-between rounded-[10px] px-4 py-3 border ${rank === 0 && played > 0 ? "border-[#a1d494]/40 bg-[#1d2a1c]" : "border-[#42493e] bg-[#1d201c]"}`}>
                <div className="flex items-center gap-3">
                  <span className={`size-7 rounded-full flex items-center justify-center text-[12px] font-bold font-['Montserrat',sans-serif] ${rank === 0 ? "bg-[#a1d494] text-[#0a3909]" : "bg-[#282b26] text-[#8c9387]"}`}>
                    {rank + 1}
                  </span>
                  <p className={`font-['Inter',sans-serif] font-medium text-[14px] ${name === "You" ? "text-[#a1d494]" : "text-[#e2e3dc]"}`}>{name}</p>
                </div>
                <div className="text-right">
                  <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[18px]">{points[name] ?? 0}</p>
                  <p className="font-['Inter',sans-serif] text-[#8c9387] text-[10px]">pts</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Match schedule */}
        <div>
          <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] uppercase tracking-[1.2px] mb-3">
            Matches ({played}/{matches.length} complete)
          </p>
          <div className="flex flex-col gap-2">
            {matches.map(([p1, p2], i) => {
              const key = `rr${i}`;
              const winner = state.winners[key];
              return (
                <div key={i} className={`rounded-[12px] border p-3 ${winner ? "border-[#42493e]/60 bg-[#1d201c]/60" : "border-[#42493e] bg-[#1d201c]"}`}>
                  <div className="flex items-center justify-between">
                    <p className="font-['Inter',sans-serif] text-[#8c9387] text-[10px] uppercase tracking-wider mb-2">Match {i + 1}</p>
                    {winner && <p className="font-['Inter',sans-serif] font-bold text-[#a1d494] text-[11px]">✓ Done</p>}
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      disabled={!!winner}
                      onClick={() => !winner && onWin(key, p1)}
                      className={`flex-1 py-2.5 rounded-[8px] text-center font-['Inter',sans-serif] font-bold text-[14px] border transition-colors
                        ${winner === p1 ? "bg-[#2d5a27] border-[#a1d494] text-[#a1d494]" : ""}
                        ${winner === p2 ? "bg-[#111410] border-[#42493e] text-[#42493e]" : ""}
                        ${!winner ? "bg-[#282b26] border-[#42493e] text-[#e2e3dc] active:bg-[#3b6934]" : ""}
                      `}>
                      {p1 === "You" ? "★ You" : p1}
                    </button>
                    <span className="font-['Inter',sans-serif] text-[#8c9387] text-[12px] font-bold">vs</span>
                    <button
                      disabled={!!winner}
                      onClick={() => !winner && onWin(key, p2)}
                      className={`flex-1 py-2.5 rounded-[8px] text-center font-['Inter',sans-serif] font-bold text-[14px] border transition-colors
                        ${winner === p2 ? "bg-[#2d5a27] border-[#a1d494] text-[#a1d494]" : ""}
                        ${winner === p1 ? "bg-[#111410] border-[#42493e] text-[#42493e]" : ""}
                        ${!winner ? "bg-[#282b26] border-[#42493e] text-[#e2e3dc] active:bg-[#3b6934]" : ""}
                      `}>
                      {p2 === "You" ? "★ You" : p2}
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        <button onClick={onDone} className="w-full bg-[#1d201c] border border-[#42493e] text-[#c2c9bb] font-['Montserrat',sans-serif] font-bold text-[14px] py-4 rounded-[12px]">
          Save & Finish
        </button>
      </div>
    </div>
  );
}

// ─── Tournaments Screen ───────────────────────────────────────────────────────

function Tournaments({ onBack }: { onBack: () => void }) {
  const [selected, setSelected] = useState<Tournament | null>(null);
  const [creating, setCreating] = useState(false);

  if (creating) return <CreateTournament onBack={() => setCreating(false)} onDone={() => setCreating(false)} />;
  if (selected) return <TournamentDetail tournament={selected} onBack={() => setSelected(null)} />;

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="Tournaments" subtitle="My competitions" />

      <div className="flex flex-col gap-4 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">

        {/* Make Your Own CTA */}
        <button onClick={() => setCreating(true)}
          className="w-full bg-[#a1d494] rounded-[14px] p-4 flex items-center gap-4 text-left">
          <div className="size-12 rounded-[10px] bg-[#0a3909]/30 flex items-center justify-center flex-shrink-0">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
              <path d="M12 4v16M4 12h16" stroke="#0a3909" strokeWidth="2.2" strokeLinecap="round" />
            </svg>
          </div>
          <div className="flex-1 min-w-0">
            <p className="font-['Montserrat',sans-serif] font-bold text-[#0a3909] text-[16px]">Make Your Own</p>
            <p className="font-['Inter',sans-serif] text-[#1a4a16] text-[13px] mt-0.5">Single · Double · Round Robin</p>
          </div>
          <svg width="8" height="13" viewBox="0 0 8 13" fill="none">
            <path d="M1 1.5L6.5 6.5L1 11.5" stroke="#0a3909" strokeWidth="2" strokeLinecap="round" />
          </svg>
        </button>

        {/* My Tournaments */}
        <p className="font-['Inter',sans-serif] font-medium text-[#8c9387] text-[12px] uppercase tracking-[1.2px] mt-2">MY TOURNAMENTS</p>

        {TOURNAMENTS.map(t => (
          <button key={t.id} onClick={() => setSelected(t)} className="text-left">
            <Card className="p-4">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[17px]">{t.name}</p>
                  <div className="flex items-center gap-1.5 mt-1.5">
                    <svg width="12" height="14" viewBox="0 0 12 14" fill="none">
                      <path d="M6 1C3.79 1 2 2.79 2 5c0 3.25 4 8 4 8s4-4.75 4-8c0-2.21-1.79-4-4-4z" fill="#c2c9bb" />
                    </svg>
                    <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px]">{t.date}</p>
                  </div>
                  <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px] mt-0.5">{t.type}</p>
                </div>
                <span className={`text-[11px] font-bold px-2.5 py-1 rounded-full ${t.status === "Active" ? "bg-[#2d5a27] text-[#a1d494]" : t.status === "Upcoming" ? "bg-[#282b26] text-[#c2c9bb]" : "bg-[#333631] text-[#c2c9bb]"}`}>
                  {t.status}
                </span>
              </div>

              {t.status !== "Upcoming" && (
                <>
                  <div className="flex items-center justify-between text-[13px] mb-1.5">
                    <p className="font-['Inter',sans-serif] text-[#c2c9bb]">{t.type} · {t.participants.length} Players</p>
                    <p className="font-['Inter',sans-serif] font-bold text-[#a1d494]">
                      {t.status === "Active" ? "75%" : "Complete"}
                    </p>
                  </div>
                  <div className="h-2 bg-[#42493e] rounded-full overflow-hidden">
                    <div className="h-full bg-[#a1d494] rounded-full" style={{ width: t.status === "Active" ? "75%" : "100%" }} />
                  </div>
                </>
              )}

              {t.result && (
                <div className="mt-3 pt-3 border-t border-[#42493e]/60 flex items-center gap-2">
                  <TrophyIcon active />
                  <p className="font-['Montserrat',sans-serif] font-semibold text-[#a1d494] text-[14px]">{t.result}</p>
                </div>
              )}

              <div className="flex items-center justify-between mt-3 pt-3 border-t border-[#42493e]/60">
                <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px]">{t.location}</p>
                <p className="font-['Inter',sans-serif] font-bold text-[#c2c9bb] text-[12px]">${t.entryFee} entry</p>
              </div>
            </Card>
          </button>
        ))}
      </div>
    </div>
  );
}

function TournamentDetail({ tournament, onBack }: { tournament: Tournament; onBack: () => void }) {
  const participants = tournament.participants.length > 0 ? tournament.participants : ["You", "Alex", "Sam", "Jordan", "Casey", "Mike", "Taylor", "Chris"];
  const [winners, setWinners] = useState<Record<string, string>>({});

  function recordWinner(key: string, w: string) {
    setWinners(prev => ({ ...prev, [key]: w }));
  }

  const seState: CreateState = {
    step: "bracket",
    format: tournament.type === "Round Robin" ? "Round Robin" : tournament.type === "Double Elimination" ? "Double Elimination" : "Single Elimination",
    name: tournament.name,
    date: tournament.date,
    location: tournament.location,
    entryFee: String(tournament.entryFee),
    players: participants,
    newPlayer: "",
    winners,
  };

  return <SEBracket state={seState} onBack={onBack} onWin={recordWinner} onDone={onBack} isDouble={tournament.type === "Double Elimination"} />;
}

// ─── Analytics Screen ─────────────────────────────────────────────────────────

function Analytics({ onBack }: { onBack: () => void }) {
  const [tab, setTab] = useState<"Overview" | "Activity" | "Courts" | "Spending">("Overview");

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="Analytics" />

      {/* Tabs */}
      <div className="border-b border-[#42493e]">
        <div className="flex gap-6 px-4 overflow-x-auto">
          {(["Overview", "Activity", "Courts", "Spending"] as const).map(t => (
            <button key={t} onClick={() => setTab(t)}
              className={`py-3.5 font-['Inter',sans-serif] font-medium text-[14px] tracking-[0.6px] relative whitespace-nowrap flex-shrink-0 ${tab === t ? "text-[#a1d494]" : "text-[#c2c9bb]"}`}>
              {t}
              {tab === t && <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#a1d494]" />}
            </button>
          ))}
        </div>
      </div>

      <div className="flex flex-col gap-5 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
        {tab === "Overview" && (
          <>
            {/* Main metric */}
            <div className="bg-[rgba(28,28,30,0.6)] border border-[rgba(44,44,46,0.8)] rounded-[12px] p-6 relative overflow-hidden" style={{ backdropFilter: "blur(6px)" }}>
              <p className="font-['Inter',sans-serif] font-medium text-[#c2c9bb] text-[13px] tracking-[0.6px]">Hours Played</p>
              <div className="flex items-baseline gap-3 mt-1">
                <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[48px] tracking-[-1px]">18.6h</p>
                <span className="font-['Inter',sans-serif] font-bold text-[#a1d494] text-[14px]">+12% <span className="text-[#c2c9bb] font-normal">vs last month</span></span>
              </div>
              <div className="h-40 mt-4 -mx-4">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={hoursData} margin={{ top: 5, right: 10, bottom: 5, left: -20 }}>
                    <defs>
                      <linearGradient id="hoursGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#a1d494" stopOpacity={0.3} />
                        <stop offset="100%" stopColor="#a1d494" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <XAxis dataKey="month" tick={{ fill: "#c2c9bb", fontSize: 11 }} axisLine={false} tickLine={false} />
                    <Tooltip contentStyle={{ background: "#1d201c", border: "1px solid #42493e", borderRadius: 8, color: "#e2e3dc" }} />
                    <Area type="monotone" dataKey="hours" stroke="#a1d494" strokeWidth={2} fill="url(#hoursGrad)" dot={false} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Sub metrics + frequency in 2-col on desktop */}
            <div className="lg:grid lg:grid-cols-2 lg:gap-5 flex flex-col gap-5">
              <div className="flex gap-3">
                {[
                  { label: "SESSIONS", value: "12" },
                  { label: "AVG. SESSION", value: "1h 33m" },
                  { label: "LONGEST", value: "2h 15m" },
                ].map(({ label, value }) => (
                  <div key={label} className="flex-1 bg-[rgba(28,28,30,0.6)] border border-[rgba(44,44,46,0.8)] rounded-[12px] p-4 flex flex-col items-center justify-center py-8" style={{ backdropFilter: "blur(6px)" }}>
                    <p className="font-['Inter',sans-serif] font-semibold text-[#c2c9bb] text-[11px] tracking-[0.6px] uppercase text-center">{label}</p>
                    <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[22px] mt-2 text-center leading-tight">{value}</p>
                  </div>
                ))}
              </div>

              {/* Play Frequency */}
              <div className="bg-[rgba(28,28,30,0.6)] border border-[rgba(44,44,46,0.8)] rounded-[12px] p-5" style={{ backdropFilter: "blur(6px)" }}>
                <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[18px] mb-4">Play Frequency</p>
                <div className="h-32">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={freqData} barSize={20}>
                      <XAxis dataKey="day" tick={{ fill: "#c2c9bb", fontSize: 10 }} axisLine={false} tickLine={false} />
                      <Bar dataKey="sessions" radius={[4, 4, 0, 0]}>
                        {freqData.map((entry, index) => (
                          <Cell key={index} fill={entry.sessions >= 3 ? "#a1d494" : "#42493e"} />
                        ))}
                      </Bar>
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </div>
            </div>
          </>
        )}

        {tab === "Activity" && (
          <>
            <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-5">
              <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[18px] mb-4">Monthly Hours Trend</p>
              <div className="h-48">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={hoursData}>
                    <XAxis dataKey="month" tick={{ fill: "#c2c9bb", fontSize: 11 }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fill: "#c2c9bb", fontSize: 10 }} axisLine={false} tickLine={false} />
                    <Tooltip contentStyle={{ background: "#1d201c", border: "1px solid #42493e", borderRadius: 8, color: "#e2e3dc" }} />
                    <Line type="monotone" dataKey="hours" stroke="#a1d494" strokeWidth={2.5} dot={{ fill: "#a1d494", r: 4 }} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>
            <div className="flex gap-3">
              <StatCard label="Total Sessions" value="44" />
              <StatCard label="Total Hours" value="64.9h" />
            </div>
            <div className="flex gap-3">
              <StatCard label="Win Rate" value="75%" sub="+5% this month" subPositive />
              <StatCard label="Streak" value="4W" sub="Personal best!" subPositive />
            </div>
          </>
        )}

        {tab === "Courts" && (
          <>
            <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-5">
              <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[18px] mb-4">Court Usage</p>
              <div className="flex items-center gap-4">
                <div className="w-36 h-36">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie data={courtUsageData} cx="50%" cy="50%" innerRadius={40} outerRadius={60} dataKey="value" strokeWidth={0}>
                        {courtUsageData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                      </Pie>
                    </PieChart>
                  </ResponsiveContainer>
                </div>
                <div className="flex flex-col gap-2">
                  {courtUsageData.map(c => (
                    <div key={c.name} className="flex items-center gap-2">
                      <div className="size-2.5 rounded-full flex-shrink-0" style={{ background: c.color }} />
                      <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px]">{c.name}</p>
                      <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[13px] ml-1">{c.value}%</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
            {COURTS.map(c => (
              <Card key={c.id} className="p-4">
                <div className="flex items-center justify-between">
                  <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[15px]">{c.name}</p>
                  <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[18px]">{c.timesPlayed}x</p>
                </div>
                <div className="mt-3 h-1.5 bg-[#42493e] rounded-full overflow-hidden">
                  <div className="h-full bg-[#a1d494] rounded-full" style={{ width: `${(c.timesPlayed / 44) * 100}%` }} />
                </div>
                <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px] mt-1.5">{c.type} · {c.surface}</p>
              </Card>
            ))}
          </>
        )}

        {tab === "Spending" && (
          <>
            <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-5">
              <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[12px] uppercase tracking-wider mb-1">Total Spent (Jun)</p>
              <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[36px] tracking-[-0.5px]">$337.40</p>
              <div className="h-36 mt-4 -mx-3">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={spendingData} margin={{ top: 5, right: 10, bottom: 0, left: -20 }}>
                    <defs>
                      <linearGradient id="spendGrad2" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#a1d494" stopOpacity={0.25} />
                        <stop offset="100%" stopColor="#a1d494" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <XAxis dataKey="month" tick={{ fill: "#c2c9bb", fontSize: 11 }} axisLine={false} tickLine={false} />
                    <Tooltip contentStyle={{ background: "#1d201c", border: "1px solid #42493e", borderRadius: 8, color: "#e2e3dc" }} formatter={(v: number) => [`$${v}`, "Spent"]} />
                    <Area type="monotone" dataKey="amount" stroke="#a1d494" strokeWidth={2} fill="url(#spendGrad2)" dot={false} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Category breakdown */}
            <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] p-5">
              <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[18px] mb-4">By Category</p>
              <div className="flex items-center gap-5">
                <div className="w-32 h-32 flex-shrink-0">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie data={expenseCategoryData} cx="50%" cy="50%" innerRadius={35} outerRadius={55} dataKey="value" strokeWidth={0}>
                        {expenseCategoryData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                      </Pie>
                    </PieChart>
                  </ResponsiveContainer>
                </div>
                <div className="flex flex-col gap-2 flex-1">
                  {expenseCategoryData.map(c => (
                    <div key={c.name} className="flex items-center gap-2 justify-between">
                      <div className="flex items-center gap-2">
                        <div className="size-2 rounded-full" style={{ background: c.color }} />
                        <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[12px]">{c.name}</p>
                      </div>
                      <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[13px]">${c.value}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

// ─── More Screen (hub for extra features) ─────────────────────────────────────

function MoreScreen({ onNav }: { onNav: (s: Screen) => void }) {
  const allItems = [
    { label: "Reservations", sub: "2 upcoming", screen: "reservations" as Screen, icon: "📅", color: "#a1d494" },
    { label: "Expenses", sub: "$337.40 this month", screen: "expenses" as Screen, icon: "💳", color: "#FFB4AB" },
    { label: "Analytics", sub: "Performance insights", screen: "analytics" as Screen, icon: "📊", color: "#c2c9bb" },
    { label: "Settings", sub: "Preferences & backup", screen: "settings" as Screen, icon: "⚙️", color: "#8c9387" },
  ];

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="More" />
      <div className="flex flex-col gap-4 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
        {/* Desktop: big feature grid; mobile: list rows */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {allItems.map(item => (
            <button key={item.label} onClick={() => onNav(item.screen)}
              className="flex items-center justify-between bg-[#1d201c] border border-[#42493e] rounded-[14px] px-4 py-5 text-left hover:border-[#a1d494]/40 transition-colors group">
              <div className="flex items-center gap-4">
                <div className="size-12 rounded-[12px] bg-[#282b26] flex items-center justify-center text-[24px] group-hover:scale-110 transition-transform">
                  {item.icon}
                </div>
                <div>
                  <p className="font-['Montserrat',sans-serif] font-semibold text-[#e2e3dc] text-[16px]">{item.label}</p>
                  <p className="font-['Inter',sans-serif] text-[#8c9387] text-[13px] mt-0.5">{item.sub}</p>
                </div>
              </div>
              <svg width="8" height="13" viewBox="0 0 8 13" fill="none">
                <path d="M1 1.5L6.5 6.5L1 11.5" stroke="#c2c9bb" strokeWidth="1.8" strokeLinecap="round" />
              </svg>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Expenses Screen ──────────────────────────────────────────────────────────

function Expenses({ onBack }: { onBack: () => void }) {
  const total = EXPENSES.reduce((a, e) => a + e.amount, 0);
  const categoryColors: Record<string, string> = {
    "Court Fees": "#a1d494",
    "Tournament Fees": "#FFB4AB",
    "Equipment": "#c2c9bb",
    "Coaching": "#3b6934",
    "Miscellaneous": "#42493e",
  };

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="Expenses" onBack={onBack} subtitle="Spending tracker" />

      <div className="flex flex-col gap-5 px-4 lg:px-8 pt-4 pb-28 lg:pb-10">
        {/* Desktop: 2-col — summary left, list right */}
        <div className="lg:grid lg:grid-cols-[300px_1fr] lg:gap-6 flex flex-col gap-5">

          {/* Left: summary + categories */}
          <div className="flex flex-col gap-4">
            <div className="bg-[#282b26] border border-[#42493e] rounded-[12px] p-5">
              <p className="font-['Inter',sans-serif] text-[#c2c9bb] text-[13px] uppercase tracking-wider">June 2025</p>
              <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[40px] tracking-[-0.5px] mt-1">${total.toFixed(2)}</p>
              <p className="font-['Inter',sans-serif] font-bold text-[#3b6934] text-[12px] mt-1">+8% vs last month</p>
            </div>
            <div className="flex gap-2 flex-wrap">
              {Object.keys(categoryColors).map(cat => (
                <div key={cat} className="px-3 py-1.5 rounded-full text-[12px] font-medium bg-[#1d201c] border border-[#42493e]"
                  style={{ color: categoryColors[cat] }}>
                  {cat}
                </div>
              ))}
            </div>
          </div>

          {/* Right: expense list */}
          <div className="flex flex-col gap-3">
            <SectionLabel>RECENT</SectionLabel>
            <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] overflow-hidden">
              {EXPENSES.map((e, i) => (
                <div key={e.id} className={`flex items-center justify-between px-4 py-4 ${i < EXPENSES.length - 1 ? "border-b border-[#1c1c1e]" : ""}`}>
                  <div className="flex items-center gap-3">
                    <div className="size-10 rounded-full flex items-center justify-center flex-shrink-0" style={{ background: categoryColors[e.category] + "22" }}>
                      <div className="size-2.5 rounded-full" style={{ background: categoryColors[e.category] }} />
                    </div>
                    <div>
                      <p className="font-['Inter',sans-serif] font-medium text-[#e2e3dc] text-[14px]">{e.category}</p>
                      <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px]">{e.date}{e.notes ? ` · ${e.notes}` : ""}</p>
                    </div>
                  </div>
                  <p className="font-['Montserrat',sans-serif] font-bold text-[#e2e3dc] text-[16px]">${e.amount.toFixed(2)}</p>
                </div>
              ))}
            </div>
          </div>

        </div>
      </div>

      <button className="fixed bottom-24 lg:bottom-8 right-5 lg:right-8 size-14 rounded-full bg-[#a1d494] flex items-center justify-center shadow-[0_10px_40px_rgba(0,0,0,0.4)] z-50">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <path d="M10 3v14M3 10h14" stroke="#0a3909" strokeWidth="2.2" strokeLinecap="round" />
        </svg>
      </button>
    </div>
  );
}

// ─── Theme System ─────────────────────────────────────────────────────────────

type AppTheme = "default" | "light" | "dark";

const THEME_CSS: Record<AppTheme, string> = {
  default: "",
  light: `
    [data-theme="light"] {
      --pd-bg:        #f2f5ef;
      --pd-bg-deep:   #e8ece4;
      --pd-card:      #ffffff;
      --pd-card2:     #f0f3ed;
      --pd-card3:     #e4e8e0;
      --pd-border:    #cdd5c6;
      --pd-text1:     #1a1f17;
      --pd-text2:     #3d4838;
      --pd-text3:     #6b7568;
      --pd-accent:    #2d6b26;
      --pd-accent-bg: rgba(45,107,38,0.12);
      --pd-accent-bg2:#1d4a18;
      --pd-win:       #1a4a15;
      --pd-lose:      #4a1527;
      --pd-header:    rgba(242,245,239,0.9);
    }
  `,
  dark: `
    [data-theme="dark"] {
      --pd-bg:        #000000;
      --pd-bg-deep:   #080808;
      --pd-card:      #111111;
      --pd-card2:     #191919;
      --pd-card3:     #222222;
      --pd-border:    #2e2e2e;
      --pd-text1:     #f0f0f0;
      --pd-text2:     #b8b8b8;
      --pd-text3:     #808080;
      --pd-accent:    #a1d494;
      --pd-accent-bg: rgba(161,212,148,0.1);
      --pd-accent-bg2:#1c3a18;
      --pd-win:       #1c3a18;
      --pd-lose:      #3a1820;
      --pd-header:    rgba(0,0,0,0.9);
    }
  `,
};

// CSS that reads the pd-* variables and overrides app colors
const THEME_OVERRIDE_CSS = `
  [data-theme="light"], [data-theme="dark"] {
    background-color: var(--pd-bg) !important;
  }
  [data-theme] .pd-bg        { background-color: var(--pd-bg) !important; }
  [data-theme] .pd-bg-deep   { background-color: var(--pd-bg-deep) !important; }
  [data-theme] .pd-card      { background-color: var(--pd-card) !important; }
  [data-theme] .pd-card2     { background-color: var(--pd-card2) !important; }
  [data-theme] .pd-card3     { background-color: var(--pd-card3) !important; }
  [data-theme] .pd-border    { border-color: var(--pd-border) !important; }
  [data-theme] .pd-text1     { color: var(--pd-text1) !important; }
  [data-theme] .pd-text2     { color: var(--pd-text2) !important; }
  [data-theme] .pd-text3     { color: var(--pd-text3) !important; }
  [data-theme] .pd-accent-t  { color: var(--pd-accent) !important; }
  [data-theme] .pd-accent-bg { background-color: var(--pd-accent-bg) !important; }

  /* Sweep all hardcoded bg colors */
  [data-theme="light"] [class*="bg-\\[\\#111410\\]"],
  [data-theme="light"] [class*="bg-\\[\\#0a0c09\\]"],
  [data-theme="light"] [class*="bg-\\[\\#0a0c0a\\]"]
    { background-color: #f2f5ef !important; }
  [data-theme="light"] [class*="bg-\\[\\#1d201c\\]"]
    { background-color: #ffffff !important; }
  [data-theme="light"] [class*="bg-\\[\\#282b26\\]"],
  [data-theme="light"] [class*="bg-\\[\\#333631\\]"]
    { background-color: #f0f3ed !important; }
  [data-theme="light"] [class*="bg-\\[\\#42493e\\]"]
    { background-color: #cdd5c6 !important; }
  [data-theme="light"] [class*="bg-\\[rgba\\(17,20,16"]
    { background-color: rgba(242,245,239,0.9) !important; }
  [data-theme="light"] [class*="bg-\\[rgba\\(29,32,28"]
    { background-color: rgba(255,255,255,0.96) !important; }
  [data-theme="light"] [class*="bg-\\[rgba\\(28,28,30"]
    { background-color: rgba(240,243,237,0.7) !important; }
  [data-theme="light"] [class*="border-\\[\\#42493e\\]"]
    { border-color: #cdd5c6 !important; }
  [data-theme="light"] [class*="border-\\[#1c1c1e\\]"]
    { border-color: #dde2d8 !important; }
  [data-theme="light"] [class*="text-\\[\\#e2e3dc\\]"]
    { color: #1a1f17 !important; }
  [data-theme="light"] [class*="text-\\[\\#c2c9bb\\]"]
    { color: #3d4838 !important; }
  [data-theme="light"] [class*="text-\\[\\#8c9387\\]"]
    { color: #6b7568 !important; }
  [data-theme="light"] [class*="text-\\[\\#a1d494\\]"]
    { color: #2d6b26 !important; }
  [data-theme="light"] [class*="bg-\\[\\#a1d494\\]"]
    { background-color: #2d6b26 !important; }
  [data-theme="light"] [class*="text-\\[\\#0a3909\\]"]
    { color: #ffffff !important; }
  [data-theme="light"] [class*="bg-\\[\\#2d5a27\\]"]
    { background-color: #c8e8c0 !important; }
  [data-theme="light"] [class*="bg-\\[\\#3b6934\\]"]
    { background-color: #b8deb0 !important; }
  [data-theme="light"] [class*="fill-\\[\\#a1d494\\]"],
  [data-theme="light"] [class*="stroke-\\[\\#a1d494\\]"]  {}
  [data-theme="light"] [class*="bg-\\[\\#474649\\]"]
    { background-color: #e0dde4 !important; }
  [data-theme="light"] aside
    { background-color: #f2f5ef !important; border-color: #cdd5c6 !important; }

  [data-theme="dark"] [class*="bg-\\[\\#111410\\]"],
  [data-theme="dark"] [class*="bg-\\[\\#0a0c09\\]"]
    { background-color: #000000 !important; }
  [data-theme="dark"] [class*="bg-\\[\\#1d201c\\]"]
    { background-color: #111111 !important; }
  [data-theme="dark"] [class*="bg-\\[\\#282b26\\]"],
  [data-theme="dark"] [class*="bg-\\[\\#333631\\]"]
    { background-color: #1a1a1a !important; }
  [data-theme="dark"] [class*="bg-\\[\\#42493e\\]"]
    { background-color: #2e2e2e !important; }
  [data-theme="dark"] [class*="bg-\\[rgba\\(17,20,16"]
    { background-color: rgba(0,0,0,0.9) !important; }
  [data-theme="dark"] [class*="bg-\\[rgba\\(29,32,28"]
    { background-color: rgba(10,10,10,0.96) !important; }
  [data-theme="dark"] [class*="bg-\\[rgba\\(28,28,30"]
    { background-color: rgba(20,20,20,0.7) !important; }
  [data-theme="dark"] [class*="border-\\[\\#42493e\\]"]
    { border-color: #2e2e2e !important; }
  [data-theme="dark"] [class*="border-\\[#1c1c1e\\]"]
    { border-color: #222222 !important; }
  [data-theme="dark"] [class*="text-\\[\\#e2e3dc\\]"]
    { color: #f0f0f0 !important; }
  [data-theme="dark"] [class*="text-\\[\\#c2c9bb\\]"]
    { color: #b8b8b8 !important; }
  [data-theme="dark"] [class*="text-\\[\\#8c9387\\]"]
    { color: #808080 !important; }
  [data-theme="dark"] aside
    { background-color: #000000 !important; border-color: #2e2e2e !important; }
`;

// ─── Settings Screen ──────────────────────────────────────────────────────────

function Settings({ onBack, theme, setTheme }: {
  onBack: () => void;
  theme: AppTheme;
  setTheme: (t: AppTheme) => void;
}) {
  const [notifications, setNotifications] = useState(true);
  const [reminders, setReminders] = useState(true);

  function Toggle({ on, onToggle }: { on: boolean; onToggle: () => void }) {
    return (
      <button onClick={onToggle}
        className={`relative inline-flex h-7 w-12 items-center rounded-full transition-colors ${on ? "bg-[#a1d494]" : "bg-[#42493e]"}`}>
        <span className={`inline-block size-5 rounded-full bg-white shadow transform transition-transform ${on ? "translate-x-6" : "translate-x-1"}`} />
      </button>
    );
  }

  const THEME_OPTIONS: { id: AppTheme; label: string; desc: string; preview: { bg: string; card: string; accent: string; text: string } }[] = [
    {
      id: "default",
      label: "Default",
      desc: "Deep green · Pickleball palette",
      preview: { bg: "#111410", card: "#1d201c", accent: "#a1d494", text: "#e2e3dc" },
    },
    {
      id: "light",
      label: "Light",
      desc: "Clean white · High contrast",
      preview: { bg: "#f2f5ef", card: "#ffffff", accent: "#2d6b26", text: "#1a1f17" },
    },
    {
      id: "dark",
      label: "Dark",
      desc: "Pure black · OLED friendly",
      preview: { bg: "#000000", card: "#111111", accent: "#a1d494", text: "#f0f0f0" },
    },
  ];

  const notifSection = [
    { label: "Push Notifications", control: <Toggle on={notifications} onToggle={() => setNotifications(!notifications)} /> },
    { label: "Reservation Reminders", control: <Toggle on={reminders} onToggle={() => setReminders(!reminders)} /> },
  ];

  const dataSection = [
    "Export Data (CSV)",
    "Export Report (PDF)",
    "Backup Data",
    "Restore from Backup",
  ];

  const ChevronR = () => (
    <svg width="8" height="13" viewBox="0 0 8 13" fill="none">
      <path d="M1 1.5L6.5 6.5L1 11.5" stroke="#c2c9bb" strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  );

  return (
    <div className="flex flex-col min-h-full">
      <TopBar title="Settings" onBack={onBack} />

      <div className="flex flex-col gap-6 px-4 lg:px-8 pt-4 pb-28 lg:pb-10 lg:max-w-2xl">

        {/* ── Theme Section ── */}
        <div>
          <p className="font-['Inter',sans-serif] font-medium text-[#8c9387] text-[12px] uppercase tracking-[1.2px] mb-3">Theme</p>
          <div className="grid grid-cols-3 gap-3">
            {THEME_OPTIONS.map(opt => {
              const isActive = theme === opt.id;
              return (
                <button
                  key={opt.id}
                  onClick={() => setTheme(opt.id)}
                  className={`rounded-[14px] overflow-hidden border-2 transition-all ${isActive ? "border-[#a1d494] scale-[1.02]" : "border-[#42493e] hover:border-[#8c9387]"}`}
                >
                  {/* Mini app preview */}
                  <div className="p-3 flex flex-col gap-1.5" style={{ background: opt.preview.bg }}>
                    {/* fake topbar */}
                    <div className="flex items-center gap-1.5">
                      <div className="size-3 rounded-full" style={{ background: opt.preview.accent + "99" }} />
                      <div className="h-1.5 rounded-full flex-1" style={{ background: opt.preview.text + "33" }} />
                    </div>
                    {/* fake card */}
                    <div className="rounded-[6px] p-2" style={{ background: opt.preview.card, border: `1px solid ${opt.preview.text}18` }}>
                      <div className="h-1.5 rounded-full w-3/4 mb-1.5" style={{ background: opt.preview.text + "55" }} />
                      <div className="h-2.5 rounded-full w-1/2" style={{ background: opt.preview.accent }} />
                    </div>
                    {/* fake bar */}
                    <div className="flex gap-1">
                      {[40, 65, 30, 80, 50].map((h, i) => (
                        <div key={i} className="flex-1 rounded-[2px]" style={{ height: h * 0.25, background: i === 3 ? opt.preview.accent : opt.preview.text + "22" }} />
                      ))}
                    </div>
                  </div>
                  {/* label */}
                  <div className="py-2.5 px-2 bg-[#1d201c] text-center">
                    <p className="font-['Montserrat',sans-serif] font-bold text-[13px]" style={{ color: isActive ? "#a1d494" : "#c2c9bb" }}>{opt.label}</p>
                    <p className="font-['Inter',sans-serif] text-[10px] text-[#8c9387] mt-0.5 leading-tight">{opt.desc}</p>
                  </div>
                  {isActive && (
                    <div className="py-1 bg-[#a1d494] text-center">
                      <p className="font-['Inter',sans-serif] font-bold text-[10px] text-[#0a3909]">✓ Active</p>
                    </div>
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* ── Notifications ── */}
        <div>
          <p className="font-['Inter',sans-serif] font-medium text-[#8c9387] text-[12px] uppercase tracking-[1.2px] mb-2">Notifications</p>
          <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] overflow-hidden">
            {notifSection.map((item, i) => (
              <div key={item.label} className={`flex items-center justify-between px-4 py-4 ${i < notifSection.length - 1 ? "border-b border-[#42493e]/50" : ""}`}>
                <p className="font-['Inter',sans-serif] font-medium text-[#e2e3dc] text-[15px]">{item.label}</p>
                {item.control}
              </div>
            ))}
          </div>
        </div>

        {/* ── Data ── */}
        <div>
          <p className="font-['Inter',sans-serif] font-medium text-[#8c9387] text-[12px] uppercase tracking-[1.2px] mb-2">Data</p>
          <div className="bg-[#1d201c] border border-[#42493e] rounded-[12px] overflow-hidden">
            {dataSection.map((label, i) => (
              <div key={label} className={`flex items-center justify-between px-4 py-4 ${i < dataSection.length - 1 ? "border-b border-[#42493e]/50" : ""}`}>
                <p className="font-['Inter',sans-serif] font-medium text-[#e2e3dc] text-[15px]">{label}</p>
                <ChevronR />
              </div>
            ))}
          </div>
        </div>

        <div className="text-center pt-2">
          <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[16px]">PickleDesk</p>
          <p className="font-['Inter',sans-serif] text-[#8c9387] text-[12px] mt-1">Version 1.0.0 · Offline First</p>
        </div>
      </div>
    </div>
  );
}

// ─── Desktop Sidebar Nav ──────────────────────────────────────────────────────

const SIDEBAR_NAV = [
  { id: "dashboard" as Screen, label: "Home", icon: HomeIcon },
  { id: "sessions" as Screen, label: "Sessions", icon: SessionIcon },
  { id: "courts" as Screen, label: "Courts", icon: CourtIcon },
  { id: "reservations" as Screen, label: "Reservations", icon: CalIcon },
  { id: "tournaments" as Screen, label: "Tournaments", icon: TrophyIcon },
  { id: "analytics" as Screen, label: "Analytics", icon: ChartIcon },
  { id: "expenses" as Screen, label: "Expenses", icon: WalletIcon },
];

function CalIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <rect x="1" y="3" width="18" height="16" rx="2.5" stroke={c} strokeWidth="1.5" />
      <path d="M1 8h18M6 1v4M14 1v4" stroke={c} strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}
function ChartIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M2 16L7 10L11 13L17 6" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M2 19h16" stroke={c} strokeWidth="1.4" strokeLinecap="round" />
    </svg>
  );
}
function WalletIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <rect x="1" y="5" width="18" height="13" rx="2.5" stroke={c} strokeWidth="1.5" />
      <path d="M1 9h18" stroke={c} strokeWidth="1.4" />
      <path d="M5 5V3.5C5 2.67 5.67 2 6.5 2h7c.83 0 1.5.67 1.5 1.5V5" stroke={c} strokeWidth="1.4" strokeLinecap="round" />
      <circle cx="14.5" cy="13" r="1.2" fill={c} />
    </svg>
  );
}
function SettingsIcon({ active }: { active: boolean }) {
  const c = active ? "#a1d494" : "#c2c9bb";
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <circle cx="10" cy="10" r="3" stroke={c} strokeWidth="1.5" />
      <path d="M10 1v2M10 17v2M1 10h2M17 10h2M3.22 3.22l1.42 1.42M15.36 15.36l1.42 1.42M3.22 16.78l1.42-1.42M15.36 4.64l1.42-1.42" stroke={c} strokeWidth="1.4" strokeLinecap="round" />
    </svg>
  );
}

function SideNav({ active, onNav }: { active: Screen; onNav: (s: Screen) => void }) {
  return (
    <aside className="hidden lg:flex flex-col w-60 flex-shrink-0 bg-[#111410] border-r border-[#42493e] h-full">
      {/* Logo */}
      <div className="px-5 py-5 border-b border-[#42493e]">
        <div className="flex items-center gap-3">
          <div className="size-9 rounded-[10px] bg-[#2d5a27] flex items-center justify-center">
            <CourtIcon active />
          </div>
          <div>
            <p className="font-['Montserrat',sans-serif] font-bold text-[#a1d494] text-[17px] leading-none">PickleDesk</p>
            <p className="font-['Inter',sans-serif] text-[#8c9387] text-[11px] mt-0.5">Personal Tracker</p>
          </div>
        </div>
      </div>

      {/* Nav items */}
      <nav className="flex-1 overflow-y-auto py-3 px-3 flex flex-col gap-0.5">
        {SIDEBAR_NAV.map(({ id, label, icon: Icon }) => {
          const isActive = active === id;
          return (
            <button key={id} onClick={() => onNav(id)}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-[10px] w-full text-left transition-colors
                ${isActive ? "bg-[#2d5a27]/50 text-[#a1d494]" : "text-[#c2c9bb] hover:bg-[#1d201c]"}`}>
              <Icon active={isActive} />
              <span className={`font-['Inter',sans-serif] font-medium text-[14px] ${isActive ? "text-[#a1d494]" : "text-[#c2c9bb]"}`}>{label}</span>
              {isActive && <div className="ml-auto w-1.5 h-1.5 rounded-full bg-[#a1d494]" />}
            </button>
          );
        })}
      </nav>

      {/* Settings at bottom */}
      <div className="px-3 pb-4 border-t border-[#42493e] pt-3">
        <button onClick={() => onNav("settings")}
          className={`flex items-center gap-3 px-3 py-2.5 rounded-[10px] w-full text-left transition-colors
            ${active === "settings" ? "bg-[#2d5a27]/50" : "hover:bg-[#1d201c]"}`}>
          <SettingsIcon active={active === "settings"} />
          <span className={`font-['Inter',sans-serif] font-medium text-[14px] ${active === "settings" ? "text-[#a1d494]" : "text-[#c2c9bb]"}`}>Settings</span>
        </button>
      </div>
    </aside>
  );
}

// ─── Root App ─────────────────────────────────────────────────────────────────

export default function App() {
  const [screen, setScreen] = useState<Screen>("dashboard");
  const [theme, setTheme] = useState<AppTheme>("default");

  function navigate(s: Screen) { setScreen(s); }

  function renderScreen() {
    switch (screen) {
      case "dashboard":    return <Dashboard onNav={navigate} />;
      case "sessions":     return <Sessions onBack={() => navigate("dashboard")} />;
      case "courts":       return <Courts onBack={() => navigate("dashboard")} />;
      case "reservations": return <Reservations onBack={() => navigate("analytics")} />;
      case "tournaments":  return <Tournaments onBack={() => navigate("dashboard")} />;
      case "analytics":    return <MoreScreen onNav={navigate} />;
      case "expenses":     return <Expenses onBack={() => navigate("analytics")} />;
      case "settings":     return <Settings onBack={() => navigate("analytics")} theme={theme} setTheme={setTheme} />;
      default:             return null;
    }
  }

  const mobileNav: Screen = (screen === "expenses" || screen === "settings" || screen === "reservations") ? "analytics" : screen;

  return (
    <div className="size-full flex bg-[#0a0c09]" data-theme={theme}>
      {/* Inject theme CSS overrides */}
      <style>{THEME_CSS[theme] + THEME_OVERRIDE_CSS}</style>

      {/* ── Desktop: sidebar fills left edge, content fills right edge ── */}
      <div className="hidden lg:flex w-full h-full">
        <SideNav active={screen} onNav={navigate} />
        <main className="flex-1 h-full overflow-y-auto bg-[#111410] min-w-0">
          {renderScreen()}
        </main>
      </div>

      {/* ── Mobile: full-width, no centering constraint ── */}
      <div className="lg:hidden flex flex-col w-full bg-[#111410] overflow-hidden">
        <div className="flex-1 overflow-y-auto overflow-x-hidden">
          {renderScreen()}
        </div>
        <BottomNav active={mobileNav} onNav={navigate} />
      </div>
    </div>
  );
}
