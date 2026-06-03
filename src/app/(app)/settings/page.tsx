"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { toast } from "sonner";
import { useAuth } from "@/hooks/useAuth";
import { useProfile } from "@/hooks/useProfile";
import { getPocketBase } from "@/lib/pocketbase";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { LogOut, UserCog } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";

const profileSchema = z.object({
  name: z.string().min(2),
  weight: z.number().min(30).max(300),
  height: z.number().min(100).max(250),
});
type ProfileValues = z.infer<typeof profileSchema>;

export default function SettingsPage() {
  const router = useRouter();
  const { user, logout } = useAuth();
  const { data: profile, isLoading } = useProfile();
  const { t } = useI18n();

  const form = useForm<ProfileValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: { name: user?.name || "", weight: 75, height: 175 },
  });

  useEffect(() => {
    if (profile) {
      form.setValue("weight", profile.weight);
      form.setValue("height", profile.height);
    }
    if (user?.name) form.setValue("name", user.name as string);
  }, [profile, user, form]);

  async function onSave(values: ProfileValues) {
    try {
      const pb = getPocketBase();
      if (user?.id) {
        await pb.collection("users").update(user.id, { name: values.name });
      }
      if (profile?.id) {
        await pb.collection("profiles").update(profile.id, {
          weight: values.weight,
          height: values.height,
        });
      }
      toast.success(t("settings.SAVED"));
    } catch {
      toast.error(t("settings.SAVE_FAILED"));
    }
  }

  function handleLogout() {
    logout();
    router.replace("/login");
  }

  return (
    <div className="mx-auto max-w-lg space-y-4 py-4">
      {/* Header */}
      <div className="border-b border-[rgba(255,255,255,0.06)] pb-4 fade-up">
        <h1 className="font-heading text-3xl font-black uppercase text-[#f0f0f0] leading-none">
          {t("settings.GEAR")}
        </h1>
        <div
          className="mt-2"
          style={{ height: 2, width: 32, background: "linear-gradient(90deg,#C2410C,transparent)", boxShadow: "0 0 8px #C2410C" }}
        />
        <p className="mt-2 font-data text-[12px] text-ink-low uppercase tracking-widest">{user?.email}</p>
      </div>

      {/* Profile */}
      <div className="glass p-4 fade-up fade-up-1">
        <div className="flex items-center gap-2 mb-4">
          <UserCog className="h-4 w-4 text-[#C2410C]" />
          <span className="font-heading text-[13px] font-bold uppercase tracking-wider text-[#f0f0f0]">
            {t("settings.PROFILE")}
          </span>
        </div>

        {isLoading ? (
          <div className="space-y-3">
            <Skeleton className="skeleton-steal h-10 w-full" />
            <Skeleton className="skeleton-steal h-10 w-full" />
          </div>
        ) : (
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSave)} className="space-y-4">
              <FormField
                control={form.control}
                name="name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="font-data text-[11px] uppercase tracking-widest text-ink-low">
                      {t("settings.DISPLAY_NAME")}
                    </FormLabel>
                    <FormControl>
                      <Input
                        className="rounded-none border-[rgba(255,255,255,0.08)] bg-[rgba(0,0,0,0.4)] font-data text-sm text-[#f0f0f0] focus:border-[#C2410C] focus-visible:ring-0"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <div className="grid gap-4 sm:grid-cols-2">
                <FormField
                  control={form.control}
                  name="weight"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-data text-[11px] uppercase tracking-widest text-ink-low">
                        {t("settings.WEIGHT_KG")}
                      </FormLabel>
                      <FormControl>
                        <Input
                          type="number"
                          step={0.1}
                          className="rounded-none border-[rgba(255,255,255,0.08)] bg-[rgba(0,0,0,0.4)] font-data text-sm text-[#f0f0f0] focus:border-[#C2410C] focus-visible:ring-0"
                          {...field}
                          onChange={(e) =>
                            field.onChange(
                              e.target.value === "" ? undefined : Number(e.target.value),
                            )
                          }
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="height"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-data text-[11px] uppercase tracking-widest text-ink-low">
                        {t("settings.HEIGHT_CM")}
                      </FormLabel>
                      <FormControl>
                        <Input
                          type="number"
                          className="rounded-none border-[rgba(255,255,255,0.08)] bg-[rgba(0,0,0,0.4)] font-data text-sm text-[#f0f0f0] focus:border-[#C2410C] focus-visible:ring-0"
                          {...field}
                          onChange={(e) =>
                            field.onChange(
                              e.target.value === "" ? undefined : Number(e.target.value),
                            )
                          }
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
              <button
                type="submit"
                disabled={form.formState.isSubmitting}
                className="btn-forge h-9 px-6 text-[11px] w-full"
              >
                {form.formState.isSubmitting ? t("settings.SAVING") : t("settings.SAVE")}
              </button>
            </form>
          </Form>
        )}
      </div>

      {/* Language */}
      <div className="glass p-4 fade-up fade-up-2">
        <span className="mb-3 block font-data text-[11px] uppercase tracking-widest text-ink-low">
          {t("settings.LANGUAGE")}
        </span>
        <div className="flex gap-2">
          {(["en", "ru", "uz"] as const).map((lang) => (
            <LanguageBtn key={lang} lang={lang} />
          ))}
        </div>
      </div>

      {/* Logout */}
      <div className="fade-up fade-up-3">
        <div style={{ height: 1, background: "rgba(255,255,255,0.06)", marginBottom: 16 }} />
        <button
          onClick={handleLogout}
          className="w-full h-9 font-data text-[11px] uppercase tracking-widest border transition-all flex items-center justify-center gap-2"
          style={{
            border: "1px solid rgba(239,68,68,0.4)",
            color: "#ef4444",
            background: "transparent",
          }}
          onMouseEnter={(e) => {
            (e.currentTarget as HTMLButtonElement).style.background = "rgba(239,68,68,0.06)";
          }}
          onMouseLeave={(e) => {
            (e.currentTarget as HTMLButtonElement).style.background = "transparent";
          }}
        >
          <LogOut className="h-3.5 w-3.5" />
          {t("settings.SIGN_OUT")}
        </button>
      </div>
    </div>
  );
}

function LanguageBtn({ lang }: { lang: "en" | "ru" | "uz" }) {
  const { language, setLanguage } = useI18n();
  const active = language === lang;
  return (
    <button
      onClick={() => setLanguage(lang)}
      className="font-data text-[11px] uppercase tracking-widest px-3 py-1.5 border transition-all"
      style={{
        border: active ? "1px solid #C2410C" : "1px solid rgba(255,255,255,0.08)",
        color: active ? "#C2410C" : "var(--ink-low)",
        background: active ? "rgba(194,65,12,0.08)" : "transparent",
      }}
    >
      {lang.toUpperCase()}
    </button>
  );
}
