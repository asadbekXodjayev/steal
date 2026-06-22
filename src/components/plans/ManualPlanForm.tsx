"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm, useFieldArray } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { toast } from "sonner";
import { getPocketBase } from "@/lib/pocketbase";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Slider } from "@/components/ui/slider";
import { MUSCLE_GROUPS } from "@/lib/constants";
import { Plus, X, ChevronDown, ChevronUp, Save, Loader2, Search } from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";
import { ExercisePickerModal } from "@/components/plans/ExercisePickerModal";
import type { LibraryExercise } from "@/types/exercise";
import Image from "next/image";

// ─── Zod schema ──────────────────────────────────────────────────────────────

const exerciseSchema = z
  .object({
    name: z.string().min(1, "Exercise name required"),
    exerciseId: z.string().optional(),
    exerciseImage: z.string().optional(),
    sets: z.number().min(1).max(20),
    repsMin: z.number().min(1).max(100),
    repsMax: z.number().min(1).max(100),
    rpeTarget: z.number().min(6).max(10),
    restSeconds: z.number().min(30).max(600),
    notes: z.string().optional(),
  })
  // Min reps can't exceed max reps (two independent inputs made this easy to do).
  .refine((e) => e.repsMax >= e.repsMin, {
    message: "Max reps must be ≥ min reps",
    path: ["repsMax"],
  });

const daySchema = z.object({
  dayOfWeek: z.number().min(1).max(7),
  label: z.string().min(1, "Day label required"),
  focus: z.array(z.string()).min(1, "Select at least one muscle group"),
  exercises: z.array(exerciseSchema).min(1, "Add at least one exercise"),
});

const manualPlanSchema = z.object({
  title: z.string().min(1, "Title required"),
  description: z.string().optional(),
  goalType: z.enum(["muscle_building", "strength", "fat_loss", "endurance", "rehabilitation"]),
  environment: z.enum(["gym", "home", "outdoor", "mixed"]),
  durationWeeks: z.number().min(1).max(52),
  days: z.array(daySchema).min(1, "Add at least one training day"),
});

type ManualPlanValues = z.infer<typeof manualPlanSchema>;
type DayValues = z.infer<typeof daySchema>;
type ExerciseValues = z.infer<typeof exerciseSchema>;

// ─── Constants ────────────────────────────────────────────────────────────────

// These are now resolved via t() in the component
const GOAL_KEYS: Record<ManualPlanValues["goalType"], string> = {
  muscle_building: "planForm.MUSCLE_BUILDING",
  strength: "planForm.STRENGTH",
  fat_loss: "planForm.FAT_LOSS",
  endurance: "planForm.ENDURANCE",
  rehabilitation: "planForm.REHABILITATION",
};

const ENV_KEYS: Record<ManualPlanValues["environment"], string> = {
  gym: "planForm.GYM",
  home: "planForm.HOME",
  outdoor: "planForm.OUTDOOR",
  mixed: "planForm.MIXED",
};

const REST_PRESETS = [
  { label: "60s", value: 60 },
  { label: "90s", value: 90 },
  { label: "2m", value: 120 },
  { label: "3m", value: 180 },
];

// ─── Sub-components ───────────────────────────────────────────────────────────

function ExerciseRow({
  index,
  dayIndex,
  form,
  onRemove,
  t,
}: {
  index: number;
  dayIndex: number;
  form: ReturnType<typeof useForm<ManualPlanValues>>;
  onRemove: () => void;
  t: (key: string) => string;
}) {
  const base = `days.${dayIndex}.exercises.${index}` as const;
  const [pickerOpen, setPickerOpen] = useState(false);

  const selectedName = form.watch(`${base}.name`);
  const selectedImage = form.watch(`${base}.exerciseImage`);

  const handlePick = (ex: LibraryExercise) => {
    form.setValue(`${base}.name`, ex.name, { shouldValidate: true });
    form.setValue(`${base}.exerciseId`, ex.exerciseId);
    form.setValue(`${base}.exerciseImage`, ex.gif || ex.image);
  };

  return (
    <div className="space-y-3 border border-border bg-[#0d0d0d] p-3">
      <div className="flex items-center justify-between">
        <span className="font-data text-[10px] font-semibold uppercase tracking-widest text-muted-foreground">
          {t("planForm.EXERCISE_N").replace("{n}", String(index + 1))}
        </span>
        <button
          type="button"
          onClick={onRemove}
          className="text-muted-foreground transition-colors hover:text-destructive"
          aria-label={t("planForm.REMOVE_EXERCISE")}
        >
          <X className="h-3.5 w-3.5" />
        </button>
      </div>

      {/* Exercise picker trigger */}
      <FormField
        control={form.control}
        name={`${base}.name`}
        render={({ fieldState }) => (
          <FormItem>
            <FormControl>
              <button
                type="button"
                onClick={() => setPickerOpen(true)}
                className={cn(
                  "w-full flex items-center gap-3 border bg-input text-left transition-colors hover:border-[#e53e00]/60",
                  fieldState.error ? "border-destructive" : "border-border",
                )}
              >
                {selectedImage ? (
                  <div className="relative h-14 w-14 shrink-0 overflow-hidden bg-[#111]">
                    <Image
                      src={selectedImage}
                      alt={selectedName || ""}
                      fill
                      className="object-cover"
                      sizes="56px"
                      unoptimized={selectedImage.endsWith(".gif")}
                    />
                  </div>
                ) : (
                  <div className="h-14 w-14 shrink-0 flex items-center justify-center bg-[#111] border-r border-border">
                    <Search className="h-4 w-4 text-[#525252]" />
                  </div>
                )}
                <div className="flex-1 min-w-0 px-2 py-2">
                  {selectedName ? (
                    <>
                      <p className="font-data text-[11px] font-bold uppercase tracking-wide text-[#e5e5e5] truncate">
                        {selectedName}
                      </p>
                      <p className="font-data text-[9px] uppercase tracking-widest text-[#e53e00] mt-0.5">
                        {t("planForm.CHANGE_EXERCISE")}
                      </p>
                    </>
                  ) : (
                    <p className="font-data text-[11px] uppercase tracking-widest text-[#525252]">
                      {t("planForm.SELECT_EXERCISE")}
                    </p>
                  )}
                </div>
              </button>
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <ExercisePickerModal
        open={pickerOpen}
        onClose={() => setPickerOpen(false)}
        onSelect={handlePick}
      />

      {/* Sets / Reps / RPE */}
      <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
        <FormField
          control={form.control}
          name={`${base}.sets`}
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                {t("planForm.SETS")}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  min={1}
                  max={20}
                  className="rounded-none border-border bg-input font-data text-sm min-h-10"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name={`${base}.repsMin`}
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                {t("planForm.REPS_MIN")}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  min={1}
                  className="rounded-none border-border bg-input font-data text-sm min-h-10"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name={`${base}.repsMax`}
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                {t("planForm.REPS_MAX")}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  min={1}
                  className="rounded-none border-border bg-input font-data text-sm min-h-10"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name={`${base}.rpeTarget`}
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                {t("planForm.RPE")}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  min={6}
                  max={10}
                  step={0.5}
                  className="rounded-none border-border bg-input font-data text-sm min-h-10"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
      </div>

      {/* Rest */}
      <FormField
        control={form.control}
        name={`${base}.restSeconds`}
        render={({ field }) => (
          <FormItem>
            <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
              {t("planForm.REST").replace("{v}", String(field.value))}
            </FormLabel>
            <div className="flex items-center gap-2">
              {REST_PRESETS.map((p) => (
                <button
                  key={p.value}
                  type="button"
                  onClick={() => field.onChange(p.value)}
                  className={cn(
                    "border px-2 py-1 font-data text-[10px] uppercase tracking-widest transition-colors",
                    field.value === p.value
                      ? "border-[#e53e00] bg-[#e53e00]/10 text-[#e53e00]"
                      : "border-border text-muted-foreground hover:border-[#e53e00]/40",
                  )}
                >
                  {p.label}
                </button>
              ))}
              <Slider
                min={30}
                max={600}
                step={15}
                value={[field.value]}
                onValueChange={([v]) => field.onChange(v)}
                className="flex-1"
              />
            </div>
            <FormMessage />
          </FormItem>
        )}
      />

      {/* Notes */}
      <FormField
        control={form.control}
        name={`${base}.notes`}
        render={({ field }) => (
          <FormItem>
            <FormControl>
              <Input
                placeholder={t("planForm.COACHING_NOTE")}
                className="rounded-none border-border bg-input font-data text-xs text-muted-foreground"
                {...field}
              />
            </FormControl>
          </FormItem>
        )}
      />
    </div>
  );
}

function DayEditor({
  dayIndex,
  form,
  onRemove,
  t,
}: {
  dayIndex: number;
  form: ReturnType<typeof useForm<ManualPlanValues>>;
  onRemove: () => void;
  t: (key: string) => string;
}) {
  const [collapsed, setCollapsed] = useState(false);
  const { fields: exFields, append: appendEx, remove: removeEx } = useFieldArray({
    control: form.control,
    name: `days.${dayIndex}.exercises`,
  });

  const dayLabel = form.watch(`days.${dayIndex}.label`) || `Day ${dayIndex + 1}`;

  const defaultExercise: ExerciseValues = {
    name: "",
    exerciseId: "",
    exerciseImage: "",
    sets: 3,
    repsMin: 8,
    repsMax: 12,
    rpeTarget: 8,
    restSeconds: 90,
    notes: "",
  };

  return (
    <div className="border border-border bg-card">
      {/* Day header */}
      <div className="flex items-center justify-between border-b border-border px-4 py-3">
        <button
          type="button"
          onClick={() => setCollapsed((c) => !c)}
          className="flex flex-1 items-center gap-3 text-left"
        >
          {collapsed ? (
            <ChevronDown className="h-4 w-4 text-muted-foreground" />
          ) : (
            <ChevronUp className="h-4 w-4 text-muted-foreground" />
          )}
          <span
            className="font-bold uppercase tracking-wide"
            style={{ fontFamily: "var(--font-heading, system-ui)" }}
          >
            {dayLabel}
          </span>
          <span className="font-data text-[10px] text-muted-foreground">
            {exFields.length} {t("planForm.EXERCISES").toLowerCase()}
          </span>
        </button>
        <button
          type="button"
          onClick={onRemove}
          className="ml-2 p-1 text-muted-foreground transition-colors hover:text-destructive"
          aria-label={t("planForm.REMOVE_DAY")}
        >
          <X className="h-4 w-4" />
        </button>
      </div>

      {!collapsed && (
        <div className="space-y-4 p-4">
          {/* Day of week + Label */}
          <div className="grid gap-3 sm:grid-cols-2">
            <FormField
              control={form.control}
              name={`days.${dayIndex}.dayOfWeek`}
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                    {t("planForm.DAY_OF_WEEK")}
                  </FormLabel>
                  <Select
                    onValueChange={(v) => field.onChange(Number(v))}
                    value={String(field.value)}
                  >
                    <FormControl>
                      <SelectTrigger className="rounded-none border-border bg-input font-data text-sm">
                        <SelectValue />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent className="rounded-none border-border bg-card">
                      {(["MON","TUE","WED","THU","FRI","SAT","SUN"] as const).map((key, i) => (
                        <SelectItem
                          key={i + 1}
                          value={String(i + 1)}
                          className="font-data text-sm uppercase tracking-wide"
                        >
                          {t(`daysOfWeek.${key}`)}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name={`days.${dayIndex}.label`}
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                    {t("planForm.SESSION_LABEL")}
                  </FormLabel>
                  <FormControl>
                    <Input
                      placeholder={t("planForm.SESSION_LABEL_PLACEHOLDER")}
                      className="rounded-none border-border bg-input font-data text-sm"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>

          {/* Muscle focus */}
          <FormField
            control={form.control}
            name={`days.${dayIndex}.focus`}
            render={({ field }) => (
              <FormItem>
                <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                  {t("planForm.MUSCLE_FOCUS")}
                </FormLabel>
                <div className="flex flex-wrap gap-1.5">
                  {MUSCLE_GROUPS.map((mg) => {
                    const selected = (field.value as string[]).includes(mg.value);
                    return (
                      <button
                        key={mg.value}
                        type="button"
                        onClick={() => {
                          const curr = field.value as string[];
                          field.onChange(
                            selected
                              ? curr.filter((v) => v !== mg.value)
                              : [...curr, mg.value],
                          );
                        }}
                        className={cn(
                          "border px-2 py-1 font-data text-[10px] uppercase tracking-widest transition-colors",
                          selected
                            ? "border-[#e53e00] bg-[#e53e00]/10 text-[#e53e00]"
                            : "border-border text-muted-foreground hover:border-[#e53e00]/40",
                        )}
                      >
                        {t(`muscles.${mg.value.toUpperCase()}`)}
                      </button>
                    );
                  })}
                </div>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Exercises */}
          <div className="space-y-2">
            <p className="label-section">{t("planForm.EXERCISES")}</p>
            {exFields.map((f, ei) => (
              <ExerciseRow
                key={f.id}
                index={ei}
                dayIndex={dayIndex}
                form={form}
                onRemove={() => removeEx(ei)}
                t={t}
              />
            ))}
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => appendEx(defaultExercise)}
              className="rounded-none border-border font-data text-xs font-bold uppercase tracking-widest hover:border-[#e53e00]/40"
            >
              <Plus className="mr-1.5 h-3 w-3" />
              {t("planForm.ADD_EXERCISE")}
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Main form ────────────────────────────────────────────────────────────────

export function ManualPlanForm() {
  const router = useRouter();
  const { t } = useI18n();
  const [saving, setSaving] = useState(false);

  const defaultDay: DayValues = {
    dayOfWeek: 1,
    label: "",
    focus: [],
    exercises: [
      { name: "", exerciseId: "", exerciseImage: "", sets: 3, repsMin: 8, repsMax: 12, rpeTarget: 8, restSeconds: 90, notes: "" },
    ],
  };

  const form = useForm<ManualPlanValues>({
    resolver: zodResolver(manualPlanSchema),
    defaultValues: {
      title: "",
      description: "",
      goalType: "muscle_building",
      environment: "gym",
      durationWeeks: 4,
      days: [defaultDay],
    },
  });

  const { fields: dayFields, append: appendDay, remove: removeDay } = useFieldArray({
    control: form.control,
    name: "days",
  });

  async function onSubmit(values: ManualPlanValues) {
    setSaving(true);
    try {
      const pb = getPocketBase();
      const userId = pb.authStore.record?.id;
      if (!userId) throw new Error("Not authenticated");

      // Create the plan
      const savedPlan = await pb.collection("workout_plans").create({
        user: userId,
        title: values.title,
        description: values.description ?? "",
        source: "custom",
        goalType: values.goalType,
        environment: values.environment,
        durationWeeks: values.durationWeeks,
        currentWeek: 1,
        status: "active",
      });

      // Repeat days across all weeks
      for (let week = 1; week <= values.durationWeeks; week++) {
        for (const day of values.days) {
          const savedDay = await pb.collection("plan_days").create({
            plan: savedPlan.id,
            week,
            dayOfWeek: day.dayOfWeek,
            label: day.label,
            focus: day.focus,
            warmup: null,
            cooldown: null,
          });

          for (let i = 0; i < day.exercises.length; i++) {
            const ex = day.exercises[i];
            await pb.collection("plan_exercises").create({
              planDay: savedDay.id,
              name: ex.name ?? "",
              order: i + 1,
              sets: ex.sets,
              repsMin: ex.repsMin,
              repsMax: ex.repsMax,
              rpeTarget: ex.rpeTarget,
              restSeconds: ex.restSeconds,
              notes: ex.notes ?? "",
              substitutions: [],
            });
          }
        }
      }

      toast.success(t("planForm.SAVED"));
      router.push(`/plans/${savedPlan.id}`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : t("planForm.SAVE_FAILED");
      toast.error(msg);
    } finally {
      setSaving(false);
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        {/* ── Plan metadata ── */}
        <div className="border border-border bg-card p-4 space-y-4">
          <p className="label-section">{t("planForm.PROGRAM_DETAILS")}</p>

          <FormField
            control={form.control}
            name="title"
            render={({ field }) => (
              <FormItem>
                <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                  {t("planForm.PROGRAM_NAME")}
                </FormLabel>
                <FormControl>
                  <Input
                    placeholder={t("planForm.PROGRAM_NAME_PLACEHOLDER")}
                    className="rounded-none border-border bg-input font-data text-sm"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="description"
            render={({ field }) => (
              <FormItem>
                <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                  {t("planForm.DESCRIPTION")}
                </FormLabel>
                <FormControl>
                  <Textarea
                    placeholder={t("planForm.DESCRIPTION_PLACEHOLDER")}
                    rows={2}
                    className="rounded-none border-border bg-input font-data text-sm"
                    {...field}
                  />
                </FormControl>
              </FormItem>
            )}
          />

          <div className="grid gap-3 sm:grid-cols-2">
            <FormField
              control={form.control}
              name="goalType"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                    {t("planForm.GOAL")}
                  </FormLabel>
                  <Select onValueChange={field.onChange} value={field.value}>
                    <FormControl>
                      <SelectTrigger className="rounded-none border-border bg-input font-data text-sm">
                        <SelectValue />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent className="rounded-none border-border bg-card">
                      {(Object.keys(GOAL_KEYS) as ManualPlanValues["goalType"][]).map((k) => (
                        <SelectItem key={k} value={k} className="font-data text-sm">
                          {t(GOAL_KEYS[k])}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="environment"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                    {t("planForm.ENVIRONMENT")}
                  </FormLabel>
                  <Select onValueChange={field.onChange} value={field.value}>
                    <FormControl>
                      <SelectTrigger className="rounded-none border-border bg-input font-data text-sm">
                        <SelectValue />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent className="rounded-none border-border bg-card">
                      {(Object.keys(ENV_KEYS) as ManualPlanValues["environment"][]).map((k) => (
                        <SelectItem key={k} value={k} className="font-data text-sm">
                          {t(ENV_KEYS[k])}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>

          <FormField
            control={form.control}
            name="durationWeeks"
            render={({ field }) => (
              <FormItem>
                <FormLabel className="font-data text-[10px] uppercase tracking-widest text-muted-foreground">
                  {t("planForm.DURATION_WEEKS").replace("{v}", String(field.value))}
                </FormLabel>
                <Slider
                  min={1}
                  max={52}
                  step={1}
                  value={[field.value]}
                  onValueChange={([v]) => field.onChange(v)}
                />
                <FormMessage />
              </FormItem>
            )}
          />
        </div>

        {/* ── Training days ── */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <p className="label-section">{t("planForm.TRAINING_DAYS")}</p>
            <span className="font-data text-[10px] text-muted-foreground">
              {t("planForm.REPEATED_ACROSS").replace("{v}", String(form.watch("durationWeeks")))}
            </span>
          </div>

          {dayFields.map((f, di) => (
            <DayEditor
              key={f.id}
              dayIndex={di}
              form={form}
              onRemove={() => removeDay(di)}
              t={t}
            />
          ))}

          {form.formState.errors.days?.root && (
            <p className="font-data text-xs text-destructive">
              {form.formState.errors.days.root.message}
            </p>
          )}

          <Button
            type="button"
            variant="outline"
            onClick={() => appendDay({ ...defaultDay, dayOfWeek: Math.min(dayFields.length + 1, 7) })}
            className="w-full rounded-none border-dashed border-border font-data text-xs font-bold uppercase tracking-widest hover:border-[#e53e00]/40"
          >
            <Plus className="mr-2 h-4 w-4" />
            {t("planForm.ADD_TRAINING_DAY")}
          </Button>
        </div>

        {/* ── Submit ── */}
        <Button
          type="submit"
          disabled={saving}
          className="w-full rounded-none bg-[#e53e00] font-data text-xs font-bold uppercase tracking-widest text-white hover:bg-[#ff4500]"
          size="lg"
        >
          {saving ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              {t("planForm.SAVING")}
            </>
          ) : (
            <>
              <Save className="mr-2 h-4 w-4" />
              {t("planForm.SAVE_PROGRAM")}
            </>
          )}
        </Button>
      </form>
    </Form>
  );
}
