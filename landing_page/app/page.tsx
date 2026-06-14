"use client";

import { useState, useEffect } from "react";
import { supabase } from "../lib/supabase";
import {
  Heart, Activity, Pill, Scale, PlayCircle, ShieldCheck,
  CheckCircle2, ChevronRight, Utensils, Bell, TrendingUp,
  Users, Star, Menu, X, Leaf, Zap, Lock, ArrowRight,
  Download, Smartphone, Globe, Award, Clock,
} from "lucide-react";

interface Links { android: string; ios: string; }

export default function Home() {
  const [links, setLinks] = useState<Links>({ android: "#", ios: "" });
  const [mobileOpen, setMobileOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    async function fetchLinks() {
      try {
        const { data } = await supabase.from("app_config").select("*");
        if (data) {
          setLinks({
            android: data.find((i: any) => i.key === "android_link")?.value || "#",
            ios:     data.find((i: any) => i.key === "ios_link")?.value || "",
          });
        }
      } catch (_) {}
    }
    fetchLinks();
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const openLink = (url: string) => { if (url && url !== "#") window.open(url, "_blank"); };

  return (
    <div className="min-h-screen font-sans text-slate-900 overflow-x-hidden" style={{ background: "#f8fafc" }}>

      {/* ── NAVBAR ─────────────────────────────────────────── */}
      <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrolled ? "bg-white shadow-md" : "bg-transparent"}`}>
        <div className="max-w-6xl mx-auto px-6 h-20 flex items-center justify-between">
          <a href="#home" className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: "linear-gradient(135deg,#10b981,#059669)" }}>
              <Leaf className="text-white" size={20} />
            </div>
            <span className="text-2xl font-bold text-slate-900">Nutri<span style={{ color: "#10b981" }}>Care</span></span>
          </a>

          <div className="hidden md:flex items-center gap-8">
            {[["#features","Features"],["#how-it-works","How It Works"],["#testimonials","Reviews"]].map(([href,label]) => (
              <a key={href} href={href} className="nav-link text-sm font-semibold text-slate-600 hover:text-emerald-600 transition-colors pb-1">{label}</a>
            ))}
            <a href="#download" className="cta-btn text-white text-sm font-bold px-6 py-3 rounded-full flex items-center gap-2">
              <Download size={15} />Download App
            </a>
          </div>

          <button onClick={() => setMobileOpen(!mobileOpen)} className="md:hidden p-2 rounded-lg hover:bg-slate-100 transition-colors">
            {mobileOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {mobileOpen && (
          <div className="md:hidden bg-white border-t border-slate-100 px-6 py-5 flex flex-col gap-4 shadow-lg">
            {[["#features","Features"],["#how-it-works","How It Works"],["#testimonials","Reviews"]].map(([href,label]) => (
              <a key={href} href={href} onClick={() => setMobileOpen(false)} className="text-slate-700 font-semibold py-1 hover:text-emerald-600 transition-colors">{label}</a>
            ))}
            <a href="#download" onClick={() => setMobileOpen(false)} className="cta-btn text-white font-bold px-6 py-3 rounded-xl text-center mt-1">
              Download Now
            </a>
          </div>
        )}
      </nav>

      {/* ── HERO ───────────────────────────────────────────── */}
      <section id="home" className="hero-gradient relative pt-36 pb-28 px-6 overflow-hidden min-h-screen flex items-center">
        {/* BG Orbs */}
        <div className="absolute top-24 left-1/4 w-96 h-96 rounded-full blur-3xl pointer-events-none" style={{ background: "rgba(16,185,129,0.10)" }} />
        <div className="absolute bottom-24 right-1/4 w-80 h-80 rounded-full blur-3xl pointer-events-none" style={{ background: "rgba(59,130,246,0.07)" }} />

        <div className="relative z-10 max-w-6xl mx-auto w-full grid lg:grid-cols-2 gap-16 items-center">
          {/* LEFT */}
          <div className="animate-slide-up">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-bold mb-8 border" style={{ background: "#d1fae5", color: "#065f46", borderColor: "rgba(16,185,129,0.3)" }}>
              <ShieldCheck size={15} />Trusted by 1,000+ Nigerian Seniors
            </div>

            <h1 className="text-5xl md:text-6xl xl:text-7xl font-extrabold leading-tight tracking-tight mb-6">
              Eat Smart.{" "}
              <span className="gradient-text">Age Well.</span>
              <br />
              Live Better.
            </h1>

            <p className="text-lg md:text-xl text-slate-600 mb-10 max-w-xl leading-relaxed">
              Nigeria's first AI-powered nutrition companion built for seniors 60+.
              Personalized meal plans, medication reminders, and health tracking —
              all using local Nigerian foods you love.
            </p>

            {/* CTA Buttons */}
            <div id="download" className="flex flex-wrap gap-4 mb-12">
              <button onClick={() => openLink(links.android)} className="cta-btn flex items-center gap-3 text-white px-7 py-4 rounded-2xl font-bold">
                <PlayCircle size={24} />
                <div className="text-left">
                  <p className="text-xs font-normal opacity-80">Get it on</p>
                  <p className="text-base font-bold -mt-0.5">Google Play</p>
                </div>
              </button>

              <button
                disabled={!links.ios}
                onClick={() => openLink(links.ios)}
                className={`flex items-center gap-3 px-7 py-4 rounded-2xl font-bold text-base transition-all border-2 ${links.ios ? "border-slate-800 text-slate-800 hover:bg-slate-800 hover:text-white" : "border-slate-200 text-slate-400 cursor-not-allowed bg-white"}`}
              >
                <Smartphone size={24} />
                <div className="text-left">
                  <p className="text-xs font-normal opacity-70">{links.ios ? "Download on the" : "iOS App"}</p>
                  <p className="text-base font-bold -mt-0.5">{links.ios ? "App Store" : "Coming Soon"}</p>
                </div>
              </button>
            </div>

            {/* Social Proof */}
            <div className="flex flex-wrap items-center gap-6">
              <div className="flex -space-x-3">
                {[
                  { bg: "#34d399", label: "A" }, { bg: "#10b981", label: "B" },
                  { bg: "#059669", label: "C" }, { bg: "#047857", label: "D" },
                ].map(({ bg, label }) => (
                  <div key={label} className="w-10 h-10 rounded-full border-2 border-white flex items-center justify-center text-white text-xs font-extrabold" style={{ background: bg }}>
                    {label}
                  </div>
                ))}
              </div>
              <div>
                <div className="flex items-center gap-1 mb-0.5">
                  {[1,2,3,4,5].map(s => <Star key={s} size={14} className="fill-amber-400 text-amber-400" />)}
                </div>
                <p className="text-sm text-slate-600 font-medium"><strong>4.9/5</strong> — Loved by seniors &amp; caregivers</p>
              </div>
            </div>
          </div>

          {/* RIGHT — Phone Mockup */}
          <div className="relative flex items-center justify-center mt-12 lg:mt-0">
            <div className="absolute w-72 h-72 rounded-full blur-3xl" style={{ background: "rgba(16,185,129,0.18)" }} />

            <div className="relative z-10 phone-frame w-72">
              <div className="bg-white rounded-[2.2rem] overflow-hidden">
                {/* Status bar + header */}
                <div className="h-28 px-5 pt-4 pb-3 flex flex-col justify-between" style={{ background: "linear-gradient(135deg,#10b981,#059669)" }}>
                  <div className="flex justify-between text-white text-xs opacity-70">
                    <span>9:41</span><span>●●● 🔋</span>
                  </div>
                  <div>
                    <p className="text-white text-xs opacity-80 font-medium">Good Morning 🌿</p>
                    <p className="text-white text-base font-bold">Alhaji Musa</p>
                  </div>
                </div>
                {/* App body */}
                <div className="p-4 space-y-3" style={{ background: "#f8fafc" }}>
                  {/* Meals card */}
                  <div className="bg-white rounded-2xl p-3.5 shadow-sm border border-slate-100">
                    <div className="flex items-center gap-2 mb-2.5">
                      <div className="w-6 h-6 rounded-lg flex items-center justify-center" style={{ background: "#d1fae5" }}>
                        <Utensils size={12} style={{ color: "#10b981" }} />
                      </div>
                      <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">Today's Meals</span>
                    </div>
                    {[
                      { meal: "Oatmeal + Plantain", cal: "320 kcal", time: "7AM", bg: "#fef3c7", color: "#92400e" },
                      { meal: "Egusi + Brown Rice",  cal: "480 kcal", time: "1PM", bg: "#d1fae5", color: "#065f46" },
                    ].map(m => (
                      <div key={m.meal} className="flex items-center justify-between mb-1">
                        <div className="flex items-center gap-1.5">
                          <span className="text-xs font-bold px-1.5 py-0.5 rounded-md" style={{ background: m.bg, color: m.color }}>{m.time}</span>
                          <span className="text-xs font-semibold text-slate-700">{m.meal}</span>
                        </div>
                        <span className="text-xs text-slate-400">{m.cal}</span>
                      </div>
                    ))}
                  </div>
                  {/* Medication */}
                  <div className="rounded-2xl p-3 flex items-center gap-2.5" style={{ background: "#eff6ff", border: "1px solid #bfdbfe" }}>
                    <div className="w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: "#3b82f6" }}>
                      <Pill size={13} className="text-white" />
                    </div>
                    <div>
                      <p className="text-xs font-bold" style={{ color: "#1e40af" }}>Medication Reminder</p>
                      <p className="text-xs" style={{ color: "#3b82f6" }}>Metformin 500mg — 15 min</p>
                    </div>
                    <div className="ml-auto w-2 h-2 rounded-full animate-pulse" style={{ background: "#3b82f6" }} />
                  </div>
                  {/* Stats */}
                  <div className="grid grid-cols-2 gap-2">
                    {[
                      { label: "Weight", value: "72.4 kg", sub: "▼ 0.8kg this week" },
                      { label: "BMI",    value: "24.1",    sub: "✓ Normal Range" },
                    ].map(s => (
                      <div key={s.label} className="bg-white rounded-xl p-2.5 text-center shadow-sm">
                        <p className="text-xs text-slate-400 mb-0.5">{s.label}</p>
                        <p className="text-sm font-extrabold text-slate-800">{s.value}</p>
                        <p className="text-xs font-semibold" style={{ color: "#10b981" }}>{s.sub}</p>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Floating badges */}
            <div className="badge-float-1 absolute -left-8 top-12 glass-card rounded-2xl px-3.5 py-3 shadow-lg flex items-center gap-2.5 z-20">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: "#d1fae5" }}>
                <Activity size={18} style={{ color: "#10b981" }} />
              </div>
              <div>
                <p className="text-xs text-slate-500 font-medium">Condition</p>
                <p className="text-xs font-extrabold text-slate-800">Diabetes Type 2</p>
              </div>
            </div>

            <div className="badge-float-2 absolute -right-6 top-1/3 glass-card rounded-2xl px-3.5 py-3 shadow-lg flex items-center gap-2.5 z-20">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: "#fef3c7" }}>
                <Bell size={18} style={{ color: "#d97706" }} />
              </div>
              <div>
                <p className="text-xs text-slate-500 font-medium">Reminder</p>
                <p className="text-xs font-extrabold text-slate-800">8:00 AM Daily</p>
              </div>
            </div>

            <div className="badge-float-3 absolute -left-4 bottom-16 glass-card rounded-2xl px-3.5 py-3 shadow-lg flex items-center gap-2.5 z-20">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: "#d1fae5" }}>
                <TrendingUp size={18} style={{ color: "#10b981" }} />
              </div>
              <div>
                <p className="text-xs text-slate-500 font-medium">Progress</p>
                <p className="text-xs font-extrabold" style={{ color: "#10b981" }}>+12% Healthier</p>
              </div>
            </div>
          </div>
        </div>

        {/* Wave divider */}
        <div className="absolute bottom-0 left-0 right-0 overflow-hidden" style={{ lineHeight: 0 }}>
          <svg viewBox="0 0 1440 70" className="w-full" preserveAspectRatio="none" height="55" fill="white">
            <path d="M0,35 C400,70 1040,0 1440,35 L1440,70 L0,70 Z" />
          </svg>
        </div>
      </section>

      {/* ── STATS BAR ──────────────────────────────────────── */}
      <section className="bg-white py-14 px-6">
        <div className="max-w-5xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-6">
          {[
            { value: "1,000+", label: "Active Users",       icon: <Users size={22} style={{ color: "#10b981" }} /> },
            { value: "50+",    label: "Nigerian Foods",     icon: <Utensils size={22} style={{ color: "#f59e0b" }} /> },
            { value: "4.9★",   label: "App Rating",         icon: <Star size={22} className="fill-amber-400 text-amber-400" /> },
            { value: "98%",    label: "Satisfaction Rate",  icon: <Heart size={22} style={{ color: "#ef4444" }} /> },
          ].map(({ value, label, icon }) => (
            <div key={label} className="stat-card flex flex-col items-center text-center gap-2">
              <div className="w-12 h-12 rounded-2xl flex items-center justify-center mb-1" style={{ background: "#f8fafc" }}>{icon}</div>
              <p className="text-3xl font-extrabold text-slate-900">{value}</p>
              <p className="text-sm text-slate-500 font-medium">{label}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── FEATURES ───────────────────────────────────────── */}
      <section id="features" className="py-24 px-6" style={{ background: "#f8fafc" }}>
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-bold mb-6 border" style={{ background: "#d1fae5", color: "#065f46", borderColor: "rgba(16,185,129,0.3)" }}>
              <Zap size={14} />Everything You Need
            </div>
            <h2 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-4 tracking-tight">
              Built for <span className="gradient-text">Nigerian Seniors</span>
            </h2>
            <p className="text-lg text-slate-500 max-w-2xl mx-auto">
              Large text, simple navigation — crafted for seniors and caregivers.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: <Activity size={26} style={{ color: "#10b981" }} />, bg: "#d1fae5", title: "Condition-Based Diet Plans", desc: "Smart recommendations for Diabetes, Hypertension, Osteoarthritis & Heart Disease using real medical guidelines.", badge: "Core Feature", badgeBg: "#d1fae5", badgeColor: "#065f46" },
              { icon: <Utensils size={26} style={{ color: "#d97706" }} />, bg: "#fef3c7", title: "Nigerian Food Database",     desc: "50+ local foods — Jollof Rice, Amala, Efo Riro, Egusi, Suya and more, with full nutritional breakdowns.", badge: "Local Foods",  badgeBg: "#fef3c7", badgeColor: "#92400e" },
              { icon: <Pill size={26} style={{ color: "#3b82f6" }} />,     bg: "#dbeafe", title: "Medication Reminders",       desc: "Never miss a dose. Custom reminders with large, clear notifications and drug-food interaction warnings.", badge: "Safety",       badgeBg: "#dbeafe", badgeColor: "#1e40af" },
              { icon: <Scale size={26} style={{ color: "#7c3aed" }} />,    bg: "#ede9fe", title: "Weight & BMI Tracking",     desc: "Log your weight, view trend charts, and get personalized goals toward a healthy BMI over time.", badge: "Analytics",    badgeBg: "#ede9fe", badgeColor: "#5b21b6" },
              { icon: <Bell size={26} style={{ color: "#ea580c" }} />,     bg: "#ffedd5", title: "Smart Daily Reminders",     desc: "Timely nudges for breakfast, lunch, dinner, water intake, and medications throughout the day.", badge: "Wellness",     badgeBg: "#ffedd5", badgeColor: "#9a3412" },
              { icon: <Lock size={26} style={{ color: "#475569" }} />,     bg: "#f1f5f9", title: "Secure & Private",          desc: "End-to-end encrypted with Supabase. Google Sign-In for secure, hassle-free access — no passwords needed.", badge: "Privacy", badgeBg: "#f1f5f9", badgeColor: "#334155" },
            ].map(({ icon, bg, title, desc, badge, badgeBg, badgeColor }) => (
              <div key={title} className="feature-card bg-white rounded-3xl p-8 border border-slate-100 shadow-sm hover:shadow-lg group">
                <div className="flex items-start justify-between mb-5">
                  <div className="w-14 h-14 rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform" style={{ background: bg }}>{icon}</div>
                  <span className="text-xs font-bold px-3 py-1.5 rounded-full" style={{ background: badgeBg, color: badgeColor }}>{badge}</span>
                </div>
                <h3 className="text-lg font-extrabold text-slate-900 mb-2 leading-snug">{title}</h3>
                <p className="text-slate-500 text-sm leading-relaxed">{desc}</p>
                <div className="mt-5 flex items-center gap-1 text-sm font-semibold opacity-0 group-hover:opacity-100 transition-opacity" style={{ color: "#10b981" }}>
                  Learn more <ChevronRight size={15} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── HOW IT WORKS ───────────────────────────────────── */}
      <section id="how-it-works" className="py-24 px-6 bg-white">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-16">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-bold mb-6 border" style={{ background: "#d1fae5", color: "#065f46", borderColor: "rgba(16,185,129,0.3)" }}>
              <Clock size={14} />Get Started in Minutes
            </div>
            <h2 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-4 tracking-tight">
              How <span className="gradient-text">NutriCare</span> Works
            </h2>
            <p className="text-lg text-slate-500">Simple steps to a healthier lifestyle. No tech expertise required.</p>
          </div>

          <div className="space-y-6">
            {[
              { step: "01", icon: <Download size={20} style={{ color: "#10b981" }} />, title: "Download & Sign Up",      desc: "Install NutriCare from Google Play. Sign up in seconds with your email or Google account — no complicated forms." },
              { step: "02", icon: <ShieldCheck size={20} style={{ color: "#10b981" }} />, title: "Set Your Health Profile", desc: "Tell us your age, conditions (diabetes, hypertension, etc.), and medications. This personalises everything for you." },
              { step: "03", icon: <Utensils size={20} style={{ color: "#10b981" }} />, title: "Get Your Meal Plan",      desc: "Receive daily personalised meal recommendations using Nigerian foods tailored to your health conditions." },
              { step: "04", icon: <TrendingUp size={20} style={{ color: "#10b981" }} />, title: "Track & Improve",        desc: "Log meals, weight, and medications. Watch your health improve through beautiful charts and progress reports." },
            ].map(({ step, icon, title, desc }, i) => (
              <div key={step} className="flex items-start gap-6 bg-white border border-slate-100 rounded-3xl p-7 shadow-sm feature-card hover:shadow-md">
                <div className="flex-shrink-0 flex flex-col items-center gap-2">
                  <div className="w-12 h-12 rounded-2xl flex items-center justify-center" style={{ background: "#d1fae5" }}>{icon}</div>
                  <span className="text-xs font-extrabold text-slate-400">STEP {step}</span>
                </div>
                <div className="flex-1 pt-1">
                  <h3 className="text-xl font-extrabold text-slate-900 mb-2">{title}</h3>
                  <p className="text-slate-500 leading-relaxed">{desc}</p>
                </div>
                <div className="flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center font-extrabold text-sm hidden md:flex" style={{ background: "#d1fae5", color: "#10b981" }}>{step}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── TESTIMONIALS ───────────────────────────────────── */}
      <section id="testimonials" className="py-24 px-6" style={{ background: "#f8fafc" }}>
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-bold mb-6 border" style={{ background: "#fef3c7", color: "#92400e", borderColor: "#fde68a" }}>
              <Star size={14} className="fill-amber-500 text-amber-500" />Real User Reviews
            </div>
            <h2 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-4 tracking-tight">
              What Our Users <span className="gradient-text">Are Saying</span>
            </h2>
            <p className="text-lg text-slate-500">Stories from seniors and caregivers across Nigeria.</p>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {[
              { initials: "AI", bg: "#10b981", name: "Alhaji Ibrahim S.", location: "Kano, Nigeria", age: "72 yrs", review: "This app changed my life. I have diabetes and never knew which Nigerian foods were safe for me. Now I eat Tuwo Shinkafa with the right portion and my sugar is stable!" },
              { initials: "CO", bg: "#3b82f6", name: "Mrs. Chidinma O.", location: "Enugu, Nigeria", age: "65 yrs", review: "My daughter installed this for me. The reminders for my blood pressure medicine are wonderful. The Egusi soup meal plan is exactly what my doctor recommended!" },
              { initials: "BA", bg: "#059669", name: "Mr. Babatunde A.", location: "Lagos, Nigeria",  age: "68 yrs", review: "I've lost 4kg in 6 weeks following the app's weight plan. My caregiver and I use it together. The BMI tracker shows my progress clearly. Very proud of this Nigerian app!" },
            ].map(({ initials, bg, name, location, age, review }) => (
              <div key={name} className="feature-card bg-white rounded-3xl p-8 border border-slate-100 shadow-sm hover:shadow-lg flex flex-col gap-5">
                <div className="flex gap-1">{[1,2,3,4,5].map(s => <Star key={s} size={16} className="fill-amber-400 text-amber-400" />)}</div>
                <p className="text-slate-700 text-sm leading-relaxed flex-1 italic">"{review}"</p>
                <div className="flex items-center gap-3 pt-4 border-t border-slate-100">
                  <div className="w-11 h-11 rounded-full flex items-center justify-center text-white font-extrabold text-sm flex-shrink-0" style={{ background: bg }}>{initials}</div>
                  <div>
                    <p className="text-sm font-bold text-slate-900">{name}</p>
                    <p className="text-xs text-slate-400">{location} · {age}</p>
                  </div>
                  <CheckCircle2 size={18} className="ml-auto" style={{ color: "#10b981" }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── DOWNLOAD CTA ───────────────────────────────────── */}
      <section id="requirements" className="py-24 px-6 bg-white">
        <div className="max-w-5xl mx-auto">
          <div className="relative rounded-3xl p-10 md:p-16 overflow-hidden text-white" style={{ background: "linear-gradient(135deg,#10b981 0%,#059669 60%,#064e3b 100%)" }}>
            <div className="absolute top-0 right-0 w-80 h-80 rounded-full blur-3xl pointer-events-none" style={{ background: "rgba(255,255,255,0.08)", transform: "translate(30%,-40%)" }} />
            <div className="absolute bottom-0 left-0 w-56 h-56 rounded-full blur-2xl pointer-events-none" style={{ background: "rgba(52,211,153,0.15)", transform: "translate(-25%,40%)" }} />

            <div className="relative z-10 grid md:grid-cols-2 gap-12 items-center">
              {/* Left */}
              <div>
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-semibold mb-6 border" style={{ background: "rgba(255,255,255,0.15)", borderColor: "rgba(255,255,255,0.25)" }}>
                  <Award size={14} />App Requirements
                </div>
                <h2 className="text-3xl md:text-4xl font-extrabold mb-5 leading-tight">Ready to Start Your Health Journey?</h2>
                <p className="text-white/80 mb-8 leading-relaxed">NutriCare is lightweight and runs great even on basic Android devices — perfect for all seniors.</p>
                <div className="grid grid-cols-2 gap-3">
                  {["Android 8.0+","Min. 2GB RAM","Internet Required","50MB Storage"].map(req => (
                    <div key={req} className="flex items-center gap-2 px-4 py-3 rounded-xl border" style={{ background: "rgba(255,255,255,0.12)", borderColor: "rgba(255,255,255,0.2)" }}>
                      <CheckCircle2 size={16} style={{ color: "#6ee7b7" }} />
                      <span className="text-sm font-semibold">{req}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Right */}
              <div className="flex flex-col gap-4">
                <p className="text-white/60 text-xs font-semibold uppercase tracking-widest mb-1">Download Now — It's Free</p>
                <button onClick={() => openLink(links.android)} className="flex items-center gap-4 bg-white rounded-2xl px-6 py-4 hover:scale-105 transition-transform shadow-lg group">
                  <div className="w-12 h-12 bg-slate-900 rounded-xl flex items-center justify-center group-hover:bg-emerald-600 transition-colors flex-shrink-0">
                    <PlayCircle size={26} className="text-white" />
                  </div>
                  <div className="text-left">
                    <p className="text-xs text-slate-500 font-medium">Available on</p>
                    <p className="text-lg font-extrabold text-slate-900">Google Play</p>
                  </div>
                  <ArrowRight size={20} className="text-slate-400 ml-auto group-hover:text-emerald-500 transition-colors" />
                </button>

                <button disabled={!links.ios} onClick={() => openLink(links.ios)}
                  className={`flex items-center gap-4 rounded-2xl px-6 py-4 transition-all ${links.ios ? "bg-white hover:scale-105 shadow-lg" : "cursor-not-allowed"}`}
                  style={!links.ios ? { background: "rgba(255,255,255,0.12)", border: "1px solid rgba(255,255,255,0.2)" } : {}}>
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 ${links.ios ? "bg-slate-900" : ""}`} style={!links.ios ? { background: "rgba(255,255,255,0.2)" } : {}}>
                    <Smartphone size={26} className="text-white" />
                  </div>
                  <div className="text-left">
                    <p className={`text-xs font-medium ${links.ios ? "text-slate-500" : "text-white/60"}`}>{links.ios ? "Available on" : "iOS Support"}</p>
                    <p className={`text-lg font-extrabold ${links.ios ? "text-slate-900" : "text-white/80"}`}>{links.ios ? "App Store" : "Coming Soon"}</p>
                  </div>
                </button>
                <p className="text-white/50 text-xs text-center mt-1">Free to download. No credit card required.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── FOOTER ─────────────────────────────────────────── */}
      <footer className="py-16 px-6" style={{ background: "#0f172a" }}>
        <div className="max-w-6xl mx-auto">
          <div className="grid md:grid-cols-4 gap-10 pb-10 border-b border-slate-800">
            <div className="md:col-span-2">
              <div className="flex items-center gap-2.5 mb-4">
                <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background: "linear-gradient(135deg,#10b981,#059669)" }}>
                  <Leaf size={18} className="text-white" />
                </div>
                <span className="text-xl font-bold text-white">Nutri<span style={{ color: "#10b981" }}>Care</span></span>
              </div>
              <p className="text-slate-400 text-sm leading-relaxed max-w-xs mb-6">Nigeria's first AI-powered dietary recommendation system for elderly people managing chronic health conditions.</p>
              <div className="flex items-center gap-2">
                {[1,2,3,4,5].map(s => <Star key={s} size={14} className="fill-amber-400 text-amber-400" />)}
                <span className="text-slate-500 text-xs ml-1">4.9 · 1,000+ users</span>
              </div>
            </div>

            <div>
              <p className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-5">Product</p>
              <ul className="space-y-3">
                {["Features","How It Works","Requirements","Download"].map(item => (
                  <li key={item}><a href={`#${item.toLowerCase().replace(" ","-")}`} className="text-sm text-slate-400 hover:text-white transition-colors">{item}</a></li>
                ))}
              </ul>
            </div>

            <div>
              <p className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-5">Support</p>
              <ul className="space-y-3">
                {[["Contact Us","mailto:support@nutricare.ng"],["Privacy Policy","#"],["Terms of Use","#"],["FAQ","#"]].map(([label,href]) => (
                  <li key={label}><a href={href} className="text-sm text-slate-400 hover:text-white transition-colors">{label}</a></li>
                ))}
              </ul>
            </div>
          </div>

          <div className="pt-8 flex flex-col md:flex-row items-center justify-between gap-4 text-slate-500 text-sm">
            <p>© 2025 NutriCare Elderly. All rights reserved. Made with ❤️ in Nigeria.</p>
            <div className="flex items-center gap-2">
              <ShieldCheck size={14} style={{ color: "#10b981" }} />
              <span>NDPR Compliant · Data Protected</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
