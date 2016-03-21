# ticket https://devops.dchbx.org/redmine/issues/5142
# this script will
# 1) fix enrollments having the wrong coverage_kind

@logger = Logger.new("#{Rails.root}/log/fix_enrollment_coverage_kind.log")

@csv = CSV.open("fixed_enrollment_coverage_kind.csv", "w")
@csv << %w(hbx_enrollment.household.family.id, hbx_enrollment.id
          hbx_enrollment.coverage_kind, hbx_enrollment.plan.coverage_kind hbx_enrollment.kind  hbx_enrollment.aasm_state
          person employer_name )


def fix_coverage_kind(families)
  families.flat_map(&:households).flat_map(&:hbx_enrollments).each do |hbx_enrollment|
    begin
      if hbx_enrollment.coverage_kind != hbx_enrollment.plan.coverage_kind

        # 1) fix enrollments having the wrong coverage_kind
        hbx_enrollment.coverage_kind = hbx_enrollment.plan.coverage_kind

        hbx_enrollment.save
        hbx_enrollment.reload

        if hbx_enrollment.subscriber
          person_name = hbx_enrollment.subscriber.person.first_name + " " + hbx_enrollment.subscriber.person.last_name
        else
          person_name = ""
        end

        if hbx_enrollment.employer_profile
          employer_name = hbx_enrollment.employer_profile.legal_name
        else
          employer_name = ""
        end

        @csv << [hbx_enrollment.household.family.id, hbx_enrollment.id, hbx_enrollment.coverage_kind,
                hbx_enrollment.plan.coverage_kind, hbx_enrollment.kind, hbx_enrollment.aasm_state, person_name, employer_name]
      end
    rescue Exception => e
      @logger.info "Family #{hbx_enrollment.household.family.id} hbx_enrollment #{hbx_enrollment.id} " + e.message + " " + e.backtrace.to_s
    end
  end

end


dental_plans = Plan.where(:coverage_kind => "dental")
dental_ids = dental_plans.map(&:id)
should_be_dental_families = Family.where({
                                             "households.hbx_enrollments" => {
                                                 "$elemMatch" => {
                                                     "coverage_kind" => "health",
                                                     "plan_id" => {"$in" => dental_ids}
                                                 }
                                             }
                                         })
fix_coverage_kind(should_be_dental_families)


health_plans = Plan.where(:coverage_kind => "health")
health_ids = health_plans.map(&:id)
should_be_health_families = Family.where({
                                             "households.hbx_enrollments" => {
                                                 "$elemMatch" => {
                                                     "coverage_kind" => "dental",
                                                     "plan_id" => {"$in" => health_ids}
                                                 }
                                             }
                                         })
fix_coverage_kind(should_be_health_families)
