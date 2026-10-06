-- Script Auto-Follow Marker / Panah Kuning untuk Glarity Reborn
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Nama folder/objek marker petunjuk di game (sesuaikan jika di Explorer namanya lain)
local MARKER_NAME = "JobMarker" -- Atau "Waypoint" / "Checkpoint"

local function getNextMarker()
    -- Mencari objek panah kuning/checkpoint aktif di Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name == MARKER_NAME or obj:IsA("CylinderHandleAdornment") or obj:IsA("MarkerModifier")) and obj.Visible ~= false then
            return obj
        end
    end
    return nil
end

local function autoDriveToMarker()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end -- Memastikan sedang naik kendaraan

    local vehicleSeat = humanoid.SeatPart -- Mengambil kendali VehicleSeat
    local targetMarker = getNextMarker()

    if targetMarker then
        local targetPos = targetMarker:IsA("BasePart") and targetMarker.Position or targetMarker.Parent.Position
        local vehiclePos = vehicleSeat.Position
        
        -- Hitung arah menuju marker
        local direction = (targetPos - vehiclePos).Unit
        local lookVector = vehicleSeat.CFrame.LookVector
        
        -- Mengemudikan kendaraan ke arah marker
        local dotProduct = lookVector:Dot(direction)
        
        if dotProduct > 0.2 then
            vehicleSeat.Throttle = 1 -- Maju
            vehicleSeat.Steer = 0
        else
            -- Belok ke arah marker
            local crossProduct = lookVector:Cross(direction)
            vehicleSeat.Throttle = 0.5
            vehicleSeat.Steer = crossProduct.Y > 0 and -1 or 1
        end
    else
        -- Jika panah tidak ditemukan / rute selesai
        vehicleSeat.Throttle = 0
        vehicleSeat.Steer = 0
    end
end

-- Menjalankan pergerakan otomatis setiap frame
RunService.RenderStepped:Connect(autoDriveToMarker)
