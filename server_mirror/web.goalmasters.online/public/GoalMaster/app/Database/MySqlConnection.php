<?php

namespace App\Database;

class MySqlConnection extends \Illuminate\Database\MySqlConnection
{
    protected function prefixQuery(string $query): string
    {
        $prefix = $this->getTablePrefix();

        if (empty($prefix)) {
            return $query;
        }

        return preg_replace_callback(
            '/\b(from|join|left\s+join|right\s+join|inner\s+join|outer\s+join|cross\s+join|update|into|delete\s+from)\s+(`?)(sch_[a-zA-Z0-9_]+)(`?)(?=\s|$)/i',
            function ($matches) use ($prefix) {

                $keyword = $matches[1];
                $quote1  = $matches[2];
                $table   = $matches[3];
                $quote2  = $matches[4];

                // لو الجدول عليه Prefix بالفعل
                if (str_starts_with($table, $prefix)) {
                    return $matches[0];
                }

                return sprintf(
                    '%s %s%s%s',
                    $keyword,
                    $quote1,
                    $prefix . $table,
                    $quote2
                );
            },
            $query
        );
    }

    public function select($query, $bindings = [], $useReadPdo = true)
    {
        $query = $this->prefixQuery($query);

        return parent::select($query, $bindings, $useReadPdo);
    }

    public function statement($query, $bindings = [])
    {
        $query = $this->prefixQuery($query);

        return parent::statement($query, $bindings);
    }

    public function affectingStatement($query, $bindings = [])
    {
        $query = $this->prefixQuery($query);

        return parent::affectingStatement($query, $bindings);
    }

    public function unprepared($query)
    {
        $query = $this->prefixQuery($query);

        return parent::unprepared($query);
    }
}