"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useTemplates } from "@/hooks/usePlans";
import { Clock, Dumbbell } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";

export function TemplateGrid() {
  const { data: templates, isLoading } = useTemplates();
  const { t } = useI18n();

  if (isLoading) {
    return (
      <div className="grid gap-4 sm:grid-cols-2">
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} className="h-48 rounded-xl" />
        ))}
      </div>
    );
  }

  if (!templates || templates.length === 0) {
    return (
      <div className="rounded-lg border border-dashed border-border p-8 text-center">
        <Dumbbell className="mx-auto h-8 w-8 text-muted-foreground" />
        <p className="mt-2 text-sm text-muted-foreground">
          {t("plans.NO_TEMPLATES")}
        </p>
      </div>
    );
  }

  return (
    <div className="grid gap-4 sm:grid-cols-2">
      {templates.map((template) => (
        <Card key={template.id} className="flex flex-col">
          <CardHeader className="pb-2">
            <div className="flex items-start justify-between">
              <CardTitle className="text-base">{template.title}</CardTitle>
              <Badge variant="outline">{template.difficulty}</Badge>
            </div>
          </CardHeader>
          <CardContent className="flex flex-1 flex-col justify-between gap-3">
            <p className="text-sm text-muted-foreground">
              {template.description}
            </p>
            <div className="space-y-3">
              <div className="flex items-center gap-4 text-xs text-muted-foreground">
                <span className="flex items-center gap-1">
                  <Clock className="h-3 w-3" />
                  {template.durationWeeks} {t("plans.WEEKS_SUFFIX")}
                </span>
                <span>{t(`enums.goalType.${template.goalType}`)}</span>
                <span>{t(`enums.environment.${template.environment}`)}</span>
              </div>
              <Button variant="outline" size="sm" className="w-full">
                {t("plans.USE_TEMPLATE")}
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
