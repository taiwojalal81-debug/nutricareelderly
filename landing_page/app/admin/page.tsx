"use client";

import { useState, useEffect } from "react";
import { supabase } from "../../lib/supabase";
import {
  Save, LogOut, Smartphone, Loader2,
  Leaf, Eye, EyeOff, ShieldCheck, AlertCircle,
  Link as LinkIcon, Apple as AppleIcon,
} from "lucide-react";

// ── Admin Credentials (local-only, no Supabase) ──────────────────────────────
const ADMIN_EMAIL    = "damilolajalal@gmail.com";
const ADMIN_PASSWORD = "jalaltaiwoelderly";
const SESSION_KEY    = "nc_admin_auth";

// ── Component ────────────────────────────────────────────────────────────────
export default function AdminPage() {
  const [authed,      setAuthed]      = useState(false);
  const [checking,    setChecking]    = useState(true); // check sessionStorage on mount
  const [email,       setEmail]       = useState("");
  const [password,    setPassword]    = useState("");
  const [showPass,    setShowPass]    = useState(false);
  const [loginError,  setLoginError]  = useState("");
  const [loggingIn,   setLoggingIn]   = useState(false);

  const [androidLink, setAndroidLink] = useState("");
  const [iosLink,     setIosLink]     = useState("");
  const [loading,     setLoading]     = useState(false);
  const [saving,      setSaving]      = useState(false);
  const [message,     setMessage]     = useState({ text: "", type: "" });

  // ── On mount: restore session from sessionStorage ──────────────────────────
  useEffect(() => {
    const stored = sessionStorage.getItem(SESSION_KEY);
    if (stored === "true") {
      setAuthed(true);
      fetchLinks();
    }
    setChecking(false);
  }, []);

  // ── Fetch app_config links from Supabase ───────────────────────────────────
  const fetchLinks = async () => {
    setLoading(true);
    const { data } = await supabase.from("app_config").select("*");
    if (data) {
      setAndroidLink(data.find((i: any) => i.key === "android_link")?.value || "");
      setIosLink(data.find((i: any) => i.key === "ios_link")?.value || "");
    }
    setLoading(false);
  };

  // ── Handle Login ───────────────────────────────────────────────────────────
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoginError("");
    setLoggingIn(true);

    // Simulate a short delay so it doesn't feel instant (UX)
    await new Promise(r => setTimeout(r, 600));

    if (
      email.trim().toLowerCase() === ADMIN_EMAIL &&
      password === ADMIN_PASSWORD
    ) {
      sessionStorage.setItem(SESSION_KEY, "true");
      setAuthed(true);
      fetchLinks();
    } else {
      setLoginError("Invalid email or password. Please try again.");
    }

    setLoggingIn(false);
  };

  // ── Handle Logout ──────────────────────────────────────────────────────────
  const handleLogout = () => {
    sessionStorage.removeItem(SESSION_KEY);
    setAuthed(false);
    setEmail("");
    setPassword("");
    setMessage({ text: "", type: "" });
    setAndroidLink("");
    setIosLink("");
  };

  // ── Save Links to Supabase ─────────────────────────────────────────────────
  const handleSave = async () => {
    setSaving(true);
    setMessage({ text: "", type: "" });

    const updates = [
      { key: "android_link", value: androidLink },
      { key: "ios_link",     value: iosLink },
    ];

    const { error } = await supabase.from("app_config").upsert(updates);

    if (error) {
      setMessage({ text: "Failed to save: " + error.message, type: "error" });
    } else {
      setMessage({ text: "✓ Links saved successfully!", type: "success" });
      setTimeout(() => setMessage({ text: "", type: "" }), 4000);
    }
    setSaving(false);
  };

  // ── Loading / checking session ─────────────────────────────────────────────
  if (checking) {
    return (
      <div className="min-h-screen flex items-center justify-center" style={{ background: "#f8fafc" }}>
        <Loader2 size={32} className="animate-spin" style={{ color: "#10b981" }} />
      </div>
    );
  }

  // ── Login Screen ───────────────────────────────────────────────────────────
  if (!authed) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4" style={{ background: "linear-gradient(135deg,#f0fdf4 0%,#f8fafc 60%,#eff6ff 100%)" }}>
        <div className="w-full max-w-md">
          {/* Card */}
          <div className="bg-white rounded-3xl shadow-xl border border-slate-100 overflow-hidden">
            {/* Header strip */}
            <div className="px-8 pt-8 pb-6 border-b border-slate-100">
              <div className="flex items-center gap-3 mb-5">
                <div className="w-11 h-11 rounded-2xl flex items-center justify-center shadow-sm" style={{ background: "linear-gradient(135deg,#10b981,#059669)" }}>
                  <Leaf size={22} className="text-white" />
                </div>
                <div>
                  <p className="text-xs font-bold uppercase tracking-widest" style={{ color: "#10b981" }}>NutriCare</p>
                  <p className="text-xs text-slate-400 font-medium">Landing Page Dashboard</p>
                </div>
              </div>
              <h1 className="text-2xl font-extrabold text-slate-900">Admin Sign In</h1>
              <p className="text-sm text-slate-500 mt-1">Restricted access — authorised personnel only.</p>
            </div>

            {/* Form */}
            <form onSubmit={handleLogin} className="px-8 py-7 space-y-5">
              {/* Email */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Email Address</label>
                <input
                  id="admin-email"
                  type="email"
                  autoComplete="email"
                  value={email}
                  onChange={e => { setEmail(e.target.value); setLoginError(""); }}
                  placeholder="admin@example.com"
                  required
                  className="w-full px-4 py-3 rounded-xl border text-sm outline-none transition-all"
                  style={{
                    borderColor: loginError ? "#fca5a5" : "#e2e8f0",
                    background: "#f8fafc",
                  }}
                  onFocus={e => (e.target.style.borderColor = "#10b981")}
                  onBlur={e => (e.target.style.borderColor = loginError ? "#fca5a5" : "#e2e8f0")}
                />
              </div>

              {/* Password */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Password</label>
                <div className="relative">
                  <input
                    id="admin-password"
                    type={showPass ? "text" : "password"}
                    autoComplete="current-password"
                    value={password}
                    onChange={e => { setPassword(e.target.value); setLoginError(""); }}
                    placeholder="Enter your password"
                    required
                    className="w-full px-4 py-3 pr-12 rounded-xl border text-sm outline-none transition-all"
                    style={{
                      borderColor: loginError ? "#fca5a5" : "#e2e8f0",
                      background: "#f8fafc",
                    }}
                    onFocus={e => (e.target.style.borderColor = "#10b981")}
                    onBlur={e => (e.target.style.borderColor = loginError ? "#fca5a5" : "#e2e8f0")}
                  />
                  <button
                    type="button"
                    tabIndex={-1}
                    onClick={() => setShowPass(!showPass)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 p-1 rounded-lg text-slate-400 hover:text-slate-600 transition-colors"
                  >
                    {showPass ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              {/* Error */}
              {loginError && (
                <div className="flex items-start gap-2.5 px-4 py-3 rounded-xl text-sm font-medium" style={{ background: "#fef2f2", color: "#b91c1c", border: "1px solid #fecaca" }}>
                  <AlertCircle size={16} className="flex-shrink-0 mt-0.5" />
                  {loginError}
                </div>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={loggingIn}
                className="w-full py-3.5 rounded-xl text-white text-sm font-bold transition-all flex items-center justify-center gap-2 disabled:opacity-70"
                style={{ background: "linear-gradient(135deg,#10b981,#059669)", boxShadow: "0 4px 16px rgba(16,185,129,0.35)" }}
              >
                {loggingIn
                  ? <><Loader2 size={18} className="animate-spin" /> Signing in…</>
                  : <><ShieldCheck size={18} /> Sign In to Dashboard</>
                }
              </button>

              {/* Security note */}
              <p className="text-center text-xs text-slate-400 pt-1">
                🔒 This login is independent of app user accounts.
              </p>
            </form>
          </div>

          <p className="text-center text-xs text-slate-400 mt-6">© 2025 NutriCare Elderly. Admin access only.</p>
        </div>
      </div>
    );
  }

  // ── Dashboard ──────────────────────────────────────────────────────────────
  return (
    <div className="min-h-screen" style={{ background: "#f8fafc" }}>
      {/* Top bar */}
      <div className="bg-white border-b border-slate-100 sticky top-0 z-40 shadow-sm">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background: "linear-gradient(135deg,#10b981,#059669)" }}>
              <Leaf size={18} className="text-white" />
            </div>
            <div>
              <p className="text-sm font-extrabold text-slate-900">NutriCare Admin</p>
              <p className="text-xs text-slate-400">Landing Page Dashboard</p>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-semibold" style={{ background: "#d1fae5", color: "#065f46" }}>
              <ShieldCheck size={13} />
              {ADMIN_EMAIL}
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold text-slate-600 hover:text-red-600 hover:bg-red-50 transition-all border border-slate-200"
            >
              <LogOut size={16} />
              Logout
            </button>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-5xl mx-auto px-6 py-10">
        <div className="mb-8">
          <h1 className="text-2xl font-extrabold text-slate-900">Download Link Management</h1>
          <p className="text-slate-500 text-sm mt-1">Update the app download links shown on the landing page.</p>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 size={30} className="animate-spin" style={{ color: "#10b981" }} />
          </div>
        ) : (
          <div className="space-y-5">
            {/* Android */}
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-7">
              <div className="flex items-center gap-3 mb-5">
                <div className="w-11 h-11 rounded-xl flex items-center justify-center" style={{ background: "#d1fae5" }}>
                  <Smartphone size={22} style={{ color: "#10b981" }} />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">Android Download Link</h2>
                  <p className="text-xs text-slate-400">Google Play Store or APK URL</p>
                </div>
              </div>
              <div className="relative">
                <LinkIcon size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                <input
                  type="url"
                  value={androidLink}
                  onChange={e => setAndroidLink(e.target.value)}
                  placeholder="https://play.google.com/store/apps/details?id=..."
                  className="w-full pl-10 pr-4 py-3 rounded-xl border text-sm outline-none transition-all"
                  style={{ borderColor: "#e2e8f0", background: "#f8fafc" }}
                  onFocus={e => (e.target.style.borderColor = "#10b981")}
                  onBlur={e => (e.target.style.borderColor = "#e2e8f0")}
                />
              </div>
              {androidLink && (
                <a href={androidLink} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 text-xs font-medium mt-2 hover:underline" style={{ color: "#10b981" }}>
                  <LinkIcon size={11} /> Preview link
                </a>
              )}
            </div>

            {/* iOS */}
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-7">
              <div className="flex items-center gap-3 mb-5">
                <div className="w-11 h-11 rounded-xl flex items-center justify-center" style={{ background: "#dbeafe" }}>
                  <AppleIcon size={22} style={{ color: "#3b82f6" }} />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">iOS Download Link</h2>
                  <p className="text-xs text-slate-400">Leave empty to show "Coming Soon" on the landing page</p>
                </div>
              </div>
              <div className="relative">
                <LinkIcon size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                <input
                  type="url"
                  value={iosLink}
                  onChange={e => setIosLink(e.target.value)}
                  placeholder="https://apps.apple.com/app/... (optional)"
                  className="w-full pl-10 pr-4 py-3 rounded-xl border text-sm outline-none transition-all"
                  style={{ borderColor: "#e2e8f0", background: "#f8fafc" }}
                  onFocus={e => (e.target.style.borderColor = "#3b82f6")}
                  onBlur={e => (e.target.style.borderColor = "#e2e8f0")}
                />
              </div>
              {!iosLink && (
                <p className="text-xs text-slate-400 mt-2">ℹ️ Landing page will show "iOS — Coming Soon" when this is empty.</p>
              )}
            </div>

            {/* Save */}
            <div className="flex items-center justify-between pt-2">
              {message.text ? (
                <div
                  className="flex items-center gap-2 px-5 py-3 rounded-xl text-sm font-semibold"
                  style={message.type === "success"
                    ? { background: "#d1fae5", color: "#065f46", border: "1px solid #6ee7b7" }
                    : { background: "#fef2f2", color: "#b91c1c", border: "1px solid #fecaca" }
                  }
                >
                  {message.type === "success" ? <ShieldCheck size={16} /> : <AlertCircle size={16} />}
                  {message.text}
                </div>
              ) : <div />}

              <button
                onClick={handleSave}
                disabled={saving}
                className="flex items-center gap-2 px-8 py-3.5 rounded-2xl text-white text-sm font-bold transition-all hover:scale-105 disabled:opacity-60 disabled:scale-100 shadow-lg"
                style={{ background: "linear-gradient(135deg,#10b981,#059669)", boxShadow: "0 4px 20px rgba(16,185,129,0.3)" }}
              >
                {saving ? <Loader2 size={18} className="animate-spin" /> : <Save size={18} />}
                {saving ? "Saving…" : "Save Changes"}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
